# VRCSplat
Gaussian splatting in VRChat

USE https://github.com/MichaelMoroz/VRChatGaussianSplatting INSTEAD! MUCH FASTER AND IMPORTS PLY DIRECTLY!
## Usage
0. (Optional, only for Example Scene with Mirror) Import [Lura's Switch ver3.00](https://booth.pm/en/items/1969082)
1. Install and run https://github.com/lambdalemon/sogs on your ply file.
2. Import the unitypackage from [releases](https://github.com/lambdalemon/vrcsplat/releases) 
3. Import the entire output directory to unity. A gaussian splat material will be generated for you inside the directory.
4. Replace the material of the mesh renderer in the example scene and enter play mode to see.
5. You will likely notice that your splats are not rotated correctly. Switching the shader to vrcsplat/GaussianSplattingOpaque makes the splats visible in scene view, which is useful for adjusting the rotation and placing other objects.
6. You might notice that some of the splats are missing. Make sure the render textures on the Sort Splats script are at least as large as your means.exr texture. If not increase their sizes. All render textures must be square, power of 2 and must have the same width and height. Tex Order should be a Texture2DArray with 2 slices, or 3 slices if your scene contains a mirror (see Example Scene with Mirror)
## Credits
Many thanks to [Michael](https://github.com/MichaelMoroz) who helped me a lot on discord, and especially for discovering how to implement radix sort in VRChat using https://github.com/d4rkc0d3r/CompactSparseTextureDemo

Based on aras-p's https://github.com/aras-p/UnityGaussianSplatting

Perspective-correct splatting from https://github.com/fhahlbohm/depthtested-gaussian-raytracing-webgl

Gaussian splat compression forked from gsplat's [png_compression](https://github.com/nerfstudio-project/gsplat/blob/main/gsplat/compression/png_compression.py) module, using [Self-Organizing Gaussians](https://github.com/fraunhoferhhi/Self-Organizing-Gaussians)

Example trained using https://github.com/fatPeter/mini-splatting2 

and the garden scene from MipNerf360 dataset https://krishnakanthnakka.github.io/mipnerf360/

Mirror Switch from [Lura's Switch ver3.00](https://booth.pm/en/items/1969082)

## Shader Variants
Two gaussian splatting shaders are included
- vrcsplat/GaussianSplattingAB: regular gaussian splatting
- vrcsplat/GaussianSplattingOpaque: opaque splats similar to https://github.com/cnlohr/slapsplat
