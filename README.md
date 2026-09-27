# SVD Virtual Body Coil for Reference-Free Coil Combination

MATLAB code and example in vivo data (3 mm, fully sampled) for reference-free coil combination at high field, using an SVD virtual body coil and ESPIRiT.

## Usage

Run `script_svd_combine.m` from the repository folder in MATLAB.

ESPIRiT is part of [BART](http://mrirecon.github.io/bart/) (Berkeley Advanced Reconstruction Toolbox). The script was tested with BART version 0.2.06, which is included in `bart-0.2.06/` for consistency (BSD license, see `bart-0.2.06/LICENSE`). The script builds it with `make` and calls its command-line tools.

## Reference

B Bilgic, JR Polimeni, LL Wald, K Setsompop. Automated tissue phase and QSM estimation from multichannel data. *ISMRM*, 2016, abstract 2849. [[HTML]](https://www.martinos.org/~berkin/2849.html)

Contact: berkin AT nmr.mgh.harvard.edu
