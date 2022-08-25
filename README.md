This is the MATLAB implementation for the technique described in the paper; <br />
**Taimoor Tariq, Cara Tursun and Piotr Didyk; [Noise-based Enhancement for Foveated Rendering](https://www.pdf.inf.usi.ch/projects/NoiseBasedEnhancement/NoiseBasedEnhancement.pdf), ACM Transactions on Graphics (SIGGRAPH 2022)**. 

Our algorithm is essentialy a human peripheral perception inspired technique to improve the quality of foveated rendering, 
allowing for more agressive shading-rate reductions without quality degradation. 

You are free to use and modify this code as you wish subject to credits. <br />
Copyright (c) 2022 by Taimoor Tariq, Cara Tursun and Piotr Didyk

The file 'example.m' provides and example of how to use the code. The code has been designed to work on 4K images. 
The parameters for the synthesis can be adjusted in the 'noise_enhancement.m' file as per requirements and/or for calibration. 
We provide two test images for users to play around with. 

NOTE: Make sure that your MATLAB is set-up for using MEX files and you have the standard 'mex.hpp', 'mexAdapter.hpp' files ready for use. 