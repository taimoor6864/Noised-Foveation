#include "mex.hpp"
#include "mexAdapter.hpp"
#include <climits>
#include <cmath>
#include "MatlabDataArray.hpp"
#include <type_traits>

template <typename T>
inline T* toPointer(const matlab::data::TypedIterator<T>& it) MW_NOEXCEPT {
	static_assert(std::is_arithmetic<T>::value && !std::is_const<T>::value,
		"Template argument T must be a std::is_arithmetic and non-const type.");
	return it.operator->();
}
/*! Extracts pointer to the first element in the array.
 *  Example usage:
 *  \code
 *  ArrayFactory factory;
 *  TypedArray<double> A = factory.createArray<double>({ 2,2 }, { 1.0, 3.0, 2.0, 4.0 });
 *  auto ptr = getPointer(A);
 *  \endcode
 *  \note Do not call `getPointer` with temporary object. e.g., the following code is ill-formed.
 *        auto ptr=getPointer(factory.createArray<double>({ 2,2 },{ 1.0, 3.0, 2.0, 4.0 }));
 */
template <typename T>
inline T* getPointer(matlab::data::TypedArray<T>& arr) MW_NOEXCEPT {
	static_assert(std::is_arithmetic<T>::value, "Template argument T must be a std::is_arithmetic type.");
	return toPointer(arr.begin());
}
template <typename T>
inline const T* getPointer(const matlab::data::TypedArray<T>& arr) MW_NOEXCEPT {
	return getPointer(const_cast<matlab::data::TypedArray<T>&>(arr));
}
