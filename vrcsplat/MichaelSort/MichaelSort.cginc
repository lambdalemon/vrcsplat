// Radix sort using d4rkpl4y3r's compact sparse textures trick, discovered by Michael.
// https://github.com/d4rkc0d3r/CompactSparseTextureDemo
// MIT License, Copyright (c) 2022 d4rkpl4y3r

#pragma vertex vert

#include "UnityCG.cginc"
#include "SortUtils.cginc"

Texture2D<float2> _MainTex; // float instead of uint so that our textures work with Hidden/BlitCopy
Texture2D _TexMeans;
float4 _TexMeans_TexelSize;
uint _N, _D;
float3 _CameraPos;


float4 vert(float4 vertex : POSITION) : SV_POSITION
{
    return UnityObjectToClipPos(vertex);
}

float4 LoadTexMeans(uint id)
{
    return _TexMeans[uint2(id % _TexMeans_TexelSize.z, id / _TexMeans_TexelSize.z)];
}

uint ComputeD(uint id)
{
    float3 mean = LoadTexMeans(id);
    float3 d = _CameraPos - mean;
    return f32tof16(length(d));
}

uint4 DigitToBin(uint d)
{
    return d == uint4(0, 1, 2, 3);
}

float2 SortPrepare(float4 vertex : SV_POSITION) : SV_Target
{
    uint id = UVToId(vertex);
    return id < _N ? ASFLOAT_NO_DENORM(uint2(id, ComputeD(id))) : 0;
}

float4 SortPassBin(float4 vertex : SV_POSITION) : SV_Target
{
    uint id = UVToId(vertex);
    uint d = asuint(_MainTex[uint2(vertex.xy)].y) >> _D & 3;
    return id < _N ? DigitToBin(d) : 0;
}

#ifdef _REORDER_PASS

Texture2D _TexBins;
float4 _TexBins_TexelSize;

uint4 CountTexels(int3 uv, int2 offset)
{
    return (float)(1 << (uv.z + uv.z)) * _TexBins.Load(uv, offset);
}

uint4 CountTexels(int3 uv)
{
    return CountTexels(uv, int2(0, 0));
}

uint2 ReorderedTexelIdToUV(uint id)
{
    int maxLod = round(log2(_TexBins_TexelSize.z));
    int3 uv = int3(0, 0, maxLod);
    uint4 binCount = CountTexels(uv);
    uint d;
    bool in3 = id < binCount.w;
    bool in2 = id < binCount.w + binCount.z;
    bool in1 = id < binCount.w + binCount.z + binCount.y;
    if (in3)
    {
        d = 3;
    }
    else if (in2)
    {
        d = 2;
        id -= binCount.w;
    }
    else if (in1)
    {
        d = 1;
        id -= binCount.w + binCount.z;
    }
    else
    {
        d = 0;
        id -= binCount.w + binCount.z + binCount.y;
    }

    uint4 activeBin = DigitToBin(d);
    while (uv.z >= 1)
    {
        uv += int3(uv.xy, -1);
        uint count00 = dot(activeBin, CountTexels(uv));
        uint count01 = dot(activeBin, CountTexels(uv, int2(1, 0)));
        uint count10 = dot(activeBin, CountTexels(uv, int2(0, 1)));
        bool in00 = id < count00;
        bool in01 = id < count00 + count01;
        bool in10 = id < count00 + count01 + count10;
        if (in00)
        {
            uv.xy += int2(0, 0);
        }
        else if (in01)
        {
            uv.xy += int2(1, 0);
            id -= count00;
        }
        else if (in10)
        {
            uv.xy += int2(0, 1);
            id -= count00 + count01;
        }
        else
        {
            uv.xy += int2(1, 1);
            id -= count00 + count01 + count10;
        }
    }
    return uv.xy;
}

float2 SortPassReorder(float4 vertex : SV_POSITION) : SV_Target
{
    uint id = UVToId(vertex);
    return id < _N ? _MainTex[ReorderedTexelIdToUV(id)] : 0;
}

#endif

uint LoadId(uint2 uv)
{
    return ASUINT_NO_DENORM(_MainTex[uv].x);
}

float4 SortDebug(float4 vertex : SV_POSITION) : SV_Target
{
    uint id = UVToId(vertex);
    if (id + 1 >= _N) return 0;
    // return LoadTexMeans(LoadId(vertex));
    uint idSelf = LoadId(vertex);
    uint idNext = LoadId(IdToUV(id + 1));
    return ComputeD(idNext) <= ComputeD(idSelf) ;
}
