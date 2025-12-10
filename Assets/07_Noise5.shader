Shader "Unlit/07_Noise5"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Density ("Density", Float) = 20.0
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
            float  _Density;

            float2 randomVec(float2 fact)
            {
                float2 angle = float2(
                    dot(fact, float2(127.1, 311.7)),
                    dot(fact, float2(269.5, 183.3))
                );
                return frac(sin(angle) * 43758.5453123) * 2.0 - 1.0;
            }

            float PerlinNoise(float density, float2 uv)
            {
                float2 uvFloor = floor(uv * density);
                float2 uvFrac  = frac(uv * density);

                float2 v00 = randomVec(uvFloor + float2(0, 0));
                float2 v01 = randomVec(uvFloor + float2(0, 1));
                float2 v10 = randomVec(uvFloor + float2(1, 0));
                float2 v11 = randomVec(uvFloor + float2(1, 1));

                float c00 = dot(v00, uvFrac - float2(0, 0));
                float c01 = dot(v01, uvFrac - float2(0, 1));
                float c10 = dot(v10, uvFrac - float2(1, 0));
                float c11 = dot(v11, uvFrac - float2(1, 1));

                float2 u = uvFrac * uvFrac * (3.0 - 2.0 * uvFrac);

                float v0010 = lerp(c00, c10, u.x);
                float v0111 = lerp(c01, c11, u.x);

                float n = lerp(v0010, v0111, u.y);

                return n * 0.5 + 0.5;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float pn = PerlinNoise(_Density, i.uv);
                fixed4 col = fixed4(pn, pn, pn, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }
    }
}
