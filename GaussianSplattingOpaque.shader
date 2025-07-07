Shader "vrcsplat/GaussianSplattingOpaque"
{
    Properties
    {
        [HideInInspector] _TexMeans ("Means", 2D) = "" {}
        [HideInInspector] _TexScales ("Scales", 2D) = "" {}
        [HideInInspector] _TexQuats ("Quats", 2D) = "" {}
        [HideInInspector] _TexColors ("Colors", 2D) = "" {}
        [HideInInspector] _ScalesMin ("Scales Min", Vector) = (0, 0, 0, 0)
        [HideInInspector] _ScalesMax ("Scales Max", Vector) = (0, 0, 0, 0)
        [HideInInspector] _TexShCentroids ("SH Centroids", 2D) = "" {}
        [HideInInspector] _ShMin ("SH Min", Float) = 0
        [HideInInspector] _ShMax ("SH Max", Float) = 0
        [Toggle] _PERSPECTIVE_CORRECT ("Perspective Correct", Float) = 1
        _AlphaCutoff ("Alpha Cutoff", Float) = 0.06
        _Log2MinScale ("Log2(MinScale), if trained with mip-splatting set this to -100", Float) = -12
        [Toggle] _ONLY_SH ("Only SH", Float) = 0
        [KeywordEnum(0th, 1st, 2nd, 3rd)] _SH_ORDER ("SH Order", Float) = 3
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" }

        Pass
        {
			Cull Off
            CGPROGRAM
        	#include "GaussianSplatting.cginc"
            ENDCG
        }
    }
}