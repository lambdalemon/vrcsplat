#pragma shader_feature_local _SH_ORDER_0TH _SH_ORDER_1ST _SH_ORDER_2ND _SH_ORDER_3RD
#pragma shader_feature_local _ONLY_SH_ON

Texture2D _TexShCentroids;
float _ShMin, _ShMax;

#if defined(_SH_ORDER_1ST)
#define _SH_ORDER 1
#elif defined(_SH_ORDER_2ND)
#define _SH_ORDER 2
#elif defined(_SH_ORDER_3RD)
#define _SH_ORDER 3
#else
#define _SH_ORDER 0
#endif

// https://github.com/aras-p/UnityGaussianSplatting
// MIT License, Copyright (c) 2023 Aras Pranckevičius

static const float SH_C1 = 0.4886025;
static const float SH_C2[] = { 1.0925484, -1.0925484, 0.3153916, -1.0925484, 0.5462742 };
static const float SH_C3[] = { -0.5900436, 2.8906114, -0.4570458, 0.3731763, -0.4570458, 1.4453057, -0.5900436 };

half3 ShadeSH(half3 col, half3 dir, uint shId)
{
    half3 sh[16];
    [unroll] for (int i = 0; i < 15; i++) {
        sh[i+1] = lerp(_ShMin, _ShMax, _TexShCentroids[uint2(i, shId)]);
    }

    dir *= -1;
    half x = dir.x, y = dir.y, z = dir.z;

    // ambient band
    #ifdef _ONLY_SH_ON
    half3 res = 0.5;
    #else
    half3 res = col; // col = sh0 * SH_C0 + 0.5 is already precomputed
    #endif

    // 1st degree
    #if _SH_ORDER >= 1
    res += SH_C1 * (-sh[1] * y + sh[2] * z - sh[3] * x);
    // 2nd degree
    #if _SH_ORDER >= 2
    half xx = x * x, yy = y * y, zz = z * z;
    half xy = x * y, yz = y * z, xz = x * z;
    res +=
        (SH_C2[0] * xy) * sh[4] +
        (SH_C2[1] * yz) * sh[5] +
        (SH_C2[2] * (2 * zz - xx - yy)) * sh[6] +
        (SH_C2[3] * xz) * sh[7] +
        (SH_C2[4] * (xx - yy)) * sh[8];
    #if _SH_ORDER >= 3
    res +=
        (SH_C3[0] * y * (3 * xx - yy)) * sh[9] +
        (SH_C3[1] * xy * z) * sh[10] +
        (SH_C3[2] * y * (4 * zz - xx - yy)) * sh[11] +
        (SH_C3[3] * z * (2 * zz - 3 * xx - 3 * yy)) * sh[12] +
        (SH_C3[4] * x * (4 * zz - xx - yy)) * sh[13] +
        (SH_C3[5] * z * (xx - yy)) * sh[14] +
        (SH_C3[6] * x * (xx - 3 * yy)) * sh[15];
    #endif
    #endif
    #endif
    return max(res, 0);
}
