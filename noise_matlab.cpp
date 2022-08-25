/* noise.cpp
* 
   This is the noise synthesis code for the paper;

 * Noise-based Enhancement for Foveated Rendering.
 * Taimoor Tariq, Cara Tarhan Tursun and Piotr Didyk.
 * ACM Transactions on Graphics (Proceedings of ACM SIGGRAPH 2022).
   
   This code is largely built upon the implementation of;
 
 * Procedural Noise using Sparse Gabor Convolution.
 * Ares Lagae, Sylvain Lefebvre, George Drettakis and Philip Dutre.
 * ACM Transactions on Graphics (Proceedings of ACM SIGGRAPH 2009) 28(3), 2009.


 * Copyright (c) 2009 by Ares Lagae, Sylvain Lefebvre,
 * George Drettakis and Philip Dutre
  
 * You are free to use amd modify this code in anyway you wish subject to credits:
 * Copyright (c) 2020 by Taimoor Tariq, Cara Tarhan Tursun and Piotr Didyk
  
 */

  // -----------------------------------------------------------------------------

#include "mex.hpp"
#include "mexAdapter.hpp"
#include <climits>
#include <cmath>
#include <ctime>
#include "C:\Users\Taimoor Tariq\source\repos\ptr_hdr.h"

#ifndef M_PI
#  define M_PI 3.14159265358979323846
#endif

class pseudo_random_number_generator
{
public:
    void seed(unsigned s) { x_ = s; }
    unsigned operator()() { x_ *= 3039177861u; return x_; }
    float uniform_0_1() { return float(operator()()) / float(UINT_MAX); }
    float uniform(float min, float max)
    {
        return min + (uniform_0_1() * (max - min));
    }
    unsigned poisson(float mean)
    {
        float g_ = std::exp(-mean);
        unsigned em = 0;
        double t = uniform_0_1();
        while (t > g_) {
            ++em;
            t *= uniform_0_1();
        }
        return em;
    }
private:
    unsigned x_;
};

float gabor(float K, float a, float F_0, float omega_0, float x, float y)
{
    float gaussian_envelop = K * std::exp(-M_PI * (a * a) * ((x * x) + (y * y)));
    float sinusoidal_carrier = std::cos(2.0 * M_PI * F_0 * ((x * std::cos(omega_0)) + (y * std::sin(omega_0))));
    return gaussian_envelop * sinusoidal_carrier;
}

unsigned morton(unsigned x, unsigned y)
{
    unsigned z = 0;
    for (unsigned i = 0; i < (sizeof(unsigned) * CHAR_BIT); ++i) {
        z |= ((x & (1 << i)) << i) | ((y & (1 << i)) << (i + 1));
    }
    return z;
}

class noise
{
public:
    noise(float K, float a, float F_0, float omega_0, float number_of_impulses_per_kernel, unsigned period, unsigned random_offset)
        : K_(K), a_(a), F_0_(F_0), omega_0_(omega_0), period_(period), random_offset_(random_offset)
    {
        kernel_radius_ = std::sqrt(-std::log(0.01) / M_PI) / a_;
        impulse_density_ = number_of_impulses_per_kernel / (M_PI * kernel_radius_ * kernel_radius_);
    }
    float operator()(float x, float y, double* or_ptr, double* k_ptr, double* Fmin_ptr, double* Fmax_ptr, unsigned res_x, unsigned res_y) const
    {
        x /= kernel_radius_, y /= kernel_radius_;
        float int_x = std::floor(x), int_y = std::floor(y);
        float frac_x = x - int_x, frac_y = y - int_y;
        int i = int(int_x), j = int(int_y);
        float noise = 0.0;
        for (int di = -1; di <= +1; ++di) {
            for (int dj = -1; dj <= +1; ++dj) {
                noise += cell(i + di, j + dj, frac_x - di, frac_y - dj, or_ptr, k_ptr, Fmin_ptr, Fmax_ptr, res_x, res_y);
            }
        }
        return noise;
    }
    float cell(int a, int b, float x, float y, double* or_ptr, double* k_ptr, double* Fmin_ptr, double* Fmax_ptr, unsigned res_x, unsigned res_y) const
    {
    	unsigned period_ = 256;
        unsigned s = (((unsigned(a) % period_) * period_) + (unsigned(b) % period_)); // periodic noise

        if (s == 0) s = 1;
        unsigned s_prime = 0.5;
        pseudo_random_number_generator prng;
        prng.seed(s);
        double number_of_impulses_per_cell = impulse_density_ * kernel_radius_ * kernel_radius_;
        unsigned number_of_impulses = prng.poisson(number_of_impulses_per_cell);
        float noise = 0.0;
        for (unsigned i = 0; i < number_of_impulses; ++i) {
            float x_i = prng.uniform_0_1();
            float y_i = prng.uniform_0_1();
            float w_i = prng.uniform(-1.0, +1.0);
            float omega_0_i = prng.uniform(0.0, 2.0 * M_PI) - M_PI;
            float omega_tt = M_PI / 4;
            float F_0_band = prng.uniform(F_0_ - 0.04, F_0_ + 0.04); 

            float x_i_x = x - x_i;
            float y_i_y = y - y_i;

            float row_prime = std::abs(std::round(kernel_radius_ * (float(b) + y_i)));
            float col_prime = std::abs(std::round(kernel_radius_ * (float(a) + x_i)));
            if (row_prime > res_x - 1) {
                row_prime = res_x - 1;
            }
            if (col_prime > res_y - 1) {
                col_prime = res_y - 1;
            }
            if (row_prime < 0) {
                row_prime = 0;
            }
            if (col_prime < 0) {
                col_prime = 0;
            }

            unsigned index = (unsigned(col_prime) * res_x) + unsigned(row_prime);
            float min_F = float(*(Fmin_ptr + index));
            float max_F = float(*(Fmax_ptr + index));

            float Freq = prng.uniform(min_F, max_F);
            if (((x_i_x * x_i_x) + (y_i_y * y_i_y)) < 1.0) {
                noise += w_i * gabor(float(*(k_ptr + index)), a_, Freq, float(*(or_ptr + index)) - (M_PI / 2), x_i_x * kernel_radius_, y_i_y * kernel_radius_); // anisotropic
            }
        }
        return noise;
    }
    float variance() const
    {
        float integral_gabor_filter_squared = ((K_ * K_) / (4.0 * a_ * a_)) * (1.0 + std::exp(-(2.0 * M_PI * F_0_ * F_0_) / (a_ * a_)));
        return impulse_density_ * (1.0 / 3.0) * integral_gabor_filter_squared;
    }
private:
    float K_;
    float a_;
    float F_0_;
    float omega_0_;
    float kernel_radius_;
    float impulse_density_;
    unsigned period_;
    unsigned random_offset_;
};

// -----------------------------------------------------------------------------

#include <ctime>
#include <fstream>
#include <iostream>



float* matlab_entry(\
    unsigned resolution_x, \
    unsigned resolution_y, \
    matlab::data::TypedArray<double> k_map, \
    float a_, \
    matlab::data::TypedArray<double> Fmin, \
    matlab::data::TypedArray<double> Fmax, \
    matlab::data::TypedArray<double> or_map, \
    float number_of_impulses_per_kernel, \
    unsigned period \
)
{
    std::cout << "Copyright (c) 2022 by Taimoor Tariq, Cara Tarhan Tursun and Piotr Didyk. " << std::endl;
    std::cout << "This code is designed for brevity and clarity. It is significantly slower than the OpenGL GPU version." << std::endl;
    // ---------------------------------------------------------------------------

 
    float K_ = 1.0;
    float F_0_ = 0.0625;
    unsigned random_offset = std::time(0);
    float omega_0_ = M_PI / 4.0;
    auto or_ptr = getPointer(or_map);
    auto k_ptr = getPointer(k_map);
    auto Fmin_ptr = getPointer(Fmin);
    auto Fmax_ptr = getPointer(Fmax);

    // ---------------------------------------------------------------------------

    noise noise_(K_, a_, F_0_, omega_0_, number_of_impulses_per_kernel, period, random_offset);
    float* image = new float[resolution_x * resolution_y];
    float scale = 3.0 * std::sqrt(noise_.variance());
    for (unsigned row = 0; row < resolution_x; ++row) {
        for (unsigned col = 0; col < resolution_y; ++col) {
            image[(row * resolution_y) + col] = 0.5 + (0.5 * (noise_(col, row, or_ptr, k_ptr, Fmin_ptr, Fmax_ptr, resolution_x, resolution_y) / scale));
        }
    }
    return image;


}

class MexFunction : public matlab::mex::Function {
    matlab::data::ArrayFactory factory;

public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        /*checkArguments(outputs, inputs);*/

        unsigned resolution_x = inputs[0][0];
        unsigned resolution_y = inputs[1][0];
        matlab::data::TypedArray<double> k_map = inputs[2];
        float a_ = inputs[3][0];
        matlab::data::TypedArray<double> Fmin = inputs[4];
        matlab::data::TypedArray<double> Fmax = inputs[5];
        float omega_0_ = inputs[4][0][0];
        matlab::data::TypedArray<double> or_map = inputs[6];
        float number_of_impulses_per_kernel = inputs[7][0];
        unsigned period = inputs[8][0];
        float* image = NULL;

        const size_t numRows = resolution_x;
        const size_t numCols = resolution_y;







        image = matlab_entry(\
            resolution_x, \
            resolution_y, \
            k_map, \
            a_, \
            Fmin, \
            Fmax, \
            or_map, \
            number_of_impulses_per_kernel, \
            period
        );
        double multiplier = inputs[0][0];
        matlab::data::TypedArray<double> result = factory.createArray<double>({ numRows, numCols });
        for (int row = 0; row < numRows; row++)
            for (int col = 0; col < numCols; col++)
                result[row][col] = image[(row * numCols) + col];

        outputs[0] = std::move(result);
    }

};
