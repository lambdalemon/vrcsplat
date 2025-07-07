#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
#define DECLARE_GRABPASS_TEXTURE UNITY_DECLARE_SCREENSPACE_TEXTURE
#define LOAD_GRABPASS_TEXTURE(tex, coord) tex[uint3(coord.xy, unity_StereoEyeIndex)]
#define SAMPLE_GRABPASS_TEXTURE UNITY_SAMPLE_SCREENSPACE_TEXTURE
#else
#define DECLARE_GRABPASS_TEXTURE UNITY_DECLARE_TEX2D
#define LOAD_GRABPASS_TEXTURE(tex, coord) tex[uint2(coord)]
#define SAMPLE_GRABPASS_TEXTURE UNITY_SAMPLE_TEX2D
#endif

DECLARE_GRABPASS_TEXTURE(_PrevFrame);

#ifdef UNITY_SINGLE_PASS_STEREO
#define SPS_OFFSETX ((int)(_ScreenParams.x * unity_StereoEyeIndex))
#define SCREEN_UV_MIN float2(0.5 * unity_StereoEyeIndex, 0)
#define SCREEN_UV_MAX float2(0.5 * (1 + unity_StereoEyeIndex), 1)
#else
#define SPS_OFFSETX 0
#define SCREEN_UV_MIN float2(0, 0)
#define SCREEN_UV_MAX float2(1, 1)
#endif

#define DEPTH_EPS 1e-5
#ifdef UNITY_REVERSED_Z
#define ALMOST_FAR_CLIP_VALUE DEPTH_EPS
#else
#define ALMOST_FAR_CLIP_VALUE (1-DEPTH_EPS)
#endif


// Pack float to SDR thanks to d4rkpl4y3r
float4 Uint8ToFloat(uint4 input)
{
    float4 o = input / 255.0;
    o.r = GammaToLinearSpaceExact(o.r);
    o.g = GammaToLinearSpaceExact(o.g);
    o.b = GammaToLinearSpaceExact(o.b);
    return o;
}

uint4 FloatToUint8(float4 input)
{
    float4 i = input;
    i.r = LinearToGammaSpaceExact(i.r);
    i.g = LinearToGammaSpaceExact(i.g);
    i.b = LinearToGammaSpaceExact(i.b);
    return uint4(round(i * 255)) & 255;
}

float4 FloatToRGBA8(float input)
{
    uint u = asuint(input);
    return Uint8ToFloat(uint4(u, u >> 8, u >> 16, u >> 24) & 255);
}

float RGBA8ToFloat(float4 input)
{
    uint4 u = FloatToUint8(input);
    return asfloat(u.x | (u.y << 8) | (u.z << 16) | (u.w << 24));
}

float GetMatrixComponent(float4x4 mat, int x) 
{
    switch (x) 
    {
        case  0: return mat._m00;
        case  1: return mat._m01;
        case  2: return mat._m02;
        case  3: return mat._m03;
        case  4: return mat._m10;
        case  5: return mat._m11;
        case  6: return mat._m12;
        case  7: return mat._m13;
        case  8: return mat._m20;
        case  9: return mat._m21;
        case 10: return mat._m22;
        case 11: return mat._m23;
        case 12: return mat._m30;
        case 13: return mat._m31;
        case 14: return mat._m32;
        case 15: return mat._m33;
        default: return 0;
    }
}

float VPMatrixComponentAtPixel(int x)
{
    return GetMatrixComponent(UNITY_MATRIX_VP, x - SPS_OFFSETX);
}

float4 EncodeGrabpassDataAtPixel(int x)
{
    return FloatToRGBA8(VPMatrixComponentAtPixel(x));
}

float DecodeGrabpassDataAtPixel(int x)
{
    return RGBA8ToFloat(LOAD_GRABPASS_TEXTURE(_PrevFrame, int2(x, 0)));
}

float4x4 LoadPrevVPMatrix()
{
    float4x4 mat;
    [unroll] for (int i = 0; i < 16; i++)
    {
        mat[i/4][i%4] = DecodeGrabpassDataAtPixel(i + SPS_OFFSETX);
    }
    return mat;
}

bool ReprojectionIsValid(float4 grabPos, float depth, float prevDepth, bool cameraIsStationary)
{
    if (cameraIsStationary) return 1;
    // if (_VRChatCameraMode > 0) return 1; // Doesn't work. Taking a photo clears previous frame grabpass??)
    float4 screenUv = grabPos / grabPos.w;
    #ifndef UNITY_REVERSED_Z
    screenUv.z = 0.5 * (screenUv.z + 1);
    #endif
    bool reprojIsValid = abs(depth - ALMOST_FAR_CLIP_VALUE) > DEPTH_EPS; // not covered by a splat this frame
    reprojIsValid = reprojIsValid && grabPos.w > 0; // reprojection behind camera
    reprojIsValid = reprojIsValid && all(screenUv.xy > SCREEN_UV_MIN && screenUv.xy < SCREEN_UV_MAX); // reprojection outside viewport
    reprojIsValid = reprojIsValid && abs(prevDepth - screenUv.z) < 1./255.; // reprojected depth different from recorded depth
    return reprojIsValid;
}
