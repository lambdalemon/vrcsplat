// adapted from: https://stackoverflow.com/questions/3137266/how-to-de-interleave-bits-unmortonizing
uint2 IdToUV(uint id)
{
    uint2 uv = uint2(id, id >> 1) & 0x55555555;
    uv = (uv | (uv >> 1)) & 0x33333333;
    uv = (uv | (uv >> 2)) & 0x0f0f0f0f;
    uv = (uv | (uv >> 4)) & 0x00ff00ff;
    uv = (uv | (uv >> 8)) & 0x0000ffff;
    return uv;
}

// adapted from: https://lemire.me/blog/2018/01/08/how-fast-can-you-bit-interleave-32-bit-integers/
uint UVToId(uint2 uv)
{
    uv = (uv ^ (uv << 8)) & 0x00ff00ff;
    uv = (uv ^ (uv << 4)) & 0x0f0f0f0f;
    uv = (uv ^ (uv << 2)) & 0x33333333;
    uv = (uv ^ (uv << 1)) & 0x55555555;
    return uv.x | uv.y << 1;
}

#define ASFLOAT_NO_DENORM(x) (asfloat(x + (1 << 30)))
#define ASUINT_NO_DENORM(x) (asuint(x) - (1 << 30))
