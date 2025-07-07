Shader "vrcsplat/EncodePrevVP"
{
    SubShader
    {
        Tags { "Queue" = "Background" }
        Pass
        {
            Cull Off
            ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "TAAUtils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // #define _DEBUG

            #ifdef _DEBUG
            #define NUM_ROWS 16
            #else
            #define NUM_ROWS 1
            #endif
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float2 quadSize = float2(16, NUM_ROWS) / _ScreenParams.xy;
                o.vertex = float4(v.uv * quadSize * 2 - 1, UNITY_NEAR_CLIP_VALUE, 1);
                o.vertex.y *= _ProjectionParams.x;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                int x = int(i.vertex.x);
                float4 color = EncodeGrabpassDataAtPixel(x);
                #ifdef _DEBUG
                if (i.vertex.y > NUM_ROWS / 2) {
                    float a = VPMatrixComponentAtPixel(x);
                    float b = DecodeGrabpassDataAtPixel(x);
                    color = abs(a - b) * 100;
                }
                #endif
                return color;
            }
            ENDCG
        }
    }
}
