This is the MATLAB (recommend v.2020a or newer) implementation for our technique described in the paper; <br />
**Taimoor Tariq, Cara Tursun and Piotr Didyk; [Noise-based Enhancement for Foveated Rendering](https://www.pdf.inf.usi.ch/projects/NoiseBasedEnhancement/), ACM Transactions on Graphics (SIGGRAPH 2022)**. 

Our algorithm essentialy exploits the limitations of human peripheral perception to improve the performance of contemporary foveated rendering systems, 
allowing for more agressive shading-rate reductions without quality degradation. 

You are free to use and modify this code as you wish subject to credits. <br />
Copyright (c) 2022 by Taimoor Tariq, Cara Tursun and Piotr Didyk

The file 'example.m' provides and example of how to use the code. The code has been designed to work on 4K images. 
The parameters for the synthesis can be adjusted in the 'noise_enhancement.m' file as per requirements and/or for calibration. 
We provide two test images for users to play around with. 

**NOTE**: Make sure that your MATLAB is set-up for using MEX files and you have the standard 'mex.hpp', 'mexAdapter.hpp' files ready for use. 

**ACKNOWLEDGEMENTS**: This project has received funding from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation program (grant agreement N◦ 804226 PERDY).
