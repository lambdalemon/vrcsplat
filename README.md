# VRCSplat
Gaussian splatting in VRChat
## Usage
1. Install and run https://github.com/lambdalemon/sogs on your ply file.
2. Import the unitypackage from [releases](https://github.com/lambdalemon/vrcsplat/releases) 
3. Import the entire output directory to unity. A gaussian splat material will be generated for you inside the directory.
4. Replace the material of the mesh renderer in the example scene and enter play mode to see.
## Credits
Many thanks to [Michael](https://github.com/MichaelMoroz) who helped me a lot on discord, and especially for discovering how to implement radix sort in VRChat using https://github.com/d4rkc0d3r/CompactSparseTextureDemo

Based on aras-p's https://github.com/aras-p/UnityGaussianSplatting

Perspective-correct splatting from https://github.com/fhahlbohm/depthtested-gaussian-raytracing-webgl

Gaussian splat compression forked from gsplat's [png_compression](https://github.com/nerfstudio-project/gsplat/blob/main/gsplat/compression/png_compression.py) module, using [Self-Organizing Gaussians](https://github.com/fraunhoferhhi/Self-Organizing-Gaussians)

Stochastic transparency from https://arxiv.org/pdf/2503.24366

Example trained using https://github.com/fatPeter/mini-splatting2 

and the garden scene from MipNerf360 dataset https://krishnakanthnakka.github.io/mipnerf360/

## Shader Variants
Three gaussian splatting shaders are included
- vrcsplat/GaussianSplattingAB: regular gaussian splatting
- vrcsplat/GaussianSplattingOpaque: opaque splats similar to https://github.com/cnlohr/slapsplat
- vrcsplat/GaussianSplattingTAA: stochastic transparency with TAA. VERY BAD DO NOT USE


