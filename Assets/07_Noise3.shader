Shader "Unlit/07_Noise3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float random(float2 v)
            {
                return frac(sin(dot(v, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float density = 10.0;
                float2 grid = floor(i.uv * density);
                float v00 = random((grid + float2(0.0, 0.0)) / density);
                float v01 = random((grid + float2(0.0, 1.0)) / density);
                float v10 = random((grid + float2(1.0, 0.0)) / density);
                float v11 = random((grid + float2(1.0, 1.0)) / density);
                float2 p = frac(i.uv * density);
                float v0010 = lerp(v00, v10, p.x);
                float v0111 = lerp(v01, v11, p.x);
                float n = lerp(v0010, v0111, p.y);
                fixed4 col = fixed4(n, n, n, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
