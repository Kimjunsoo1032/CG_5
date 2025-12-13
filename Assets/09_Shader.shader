Shader "Unlit/09_Shader"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "white" {}
        _SubTex ("SubTexture", 2D) = "black" {}
        _HeightTex ("Height", 2D) = "black" {}
        _ParallaxShallow ("Shallow Parallax Scale", Range(0, 0.5)) = 0
        _ParallaxDeep ("Deep Parallax Scale", Range(0, 0.5)) = 0.05
        _MainParallax ("MainParallaxScale", Range(0, 1)) = 0.5
        _SubParallax ("SubParallaxScale", Range(0, 1)) = 0.5
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 viewDirTS : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SubTex;
            sampler2D _HeightTex;

            float4 _MainTex_ST;
            float4 _SubTex_ST;
            float4 _HeightTex_ST;

            float _ParallaxShallow;
            float _ParallaxDeep;
            float _MainParallax;
            float _SubParallax;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;

                float3 t = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float3 n = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 b = normalize(cross(n, t) * v.tangent.w * unity_WorldTransformParams.w);

                float3x3 matTBN = float3x3(t, b, n);
                o.viewDirTS = mul(matTBN, viewDirWS);

                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirTS = normalize(-i.viewDirTS);

                float2 mainUV = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 subUV  = i.uv * _SubTex_ST.xy  + _SubTex_ST.zw;
                float2 hUV    = i.uv * _HeightTex_ST.xy + _HeightTex_ST.zw;

                float height = tex2D(_HeightTex, hUV).r;

                float2 shallowOffset = viewDirTS.xy * _ParallaxShallow;
                float2 deepOffset    = viewDirTS.xy * _ParallaxDeep;
                float2 heightOffset  = lerp(shallowOffset, deepOffset, height);

                float2 mainOffset = viewDirTS.xy * _MainParallax;
                float2 subOffset  = viewDirTS.xy * _SubParallax;

                float2 mainUV2 = mainUV + heightOffset + mainOffset;
                float2 subUV2  = subUV  + heightOffset + subOffset;

                fixed4 mainCol = tex2D(_MainTex, mainUV2);
                fixed4 subCol  = tex2D(_SubTex,  subUV2);

                fixed4 col = lerp(mainCol, subCol, subCol.a);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
