Shader "vrcsplat/MichaelSort"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TexMeans ("Splat Means", 2D) = "white" {}
        _TexBins ("Bins", 2D) = "white" {}
        _N ("# of Splats", Int) = 0
        _D ("Digit", Int) = 0
        _CameraPos ("CameraPos", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #include "MichaelSort.cginc"
            #pragma fragment SortPrepare // 0
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #include "MichaelSort.cginc"
            #pragma fragment SortPassBin // 1
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define _REORDER_PASS
            #include "MichaelSort.cginc"
            #pragma fragment SortPassReorder // 2
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #include "MichaelSort.cginc"
            #pragma fragment SortDebug // 3
            ENDCG
        }
    }
}
