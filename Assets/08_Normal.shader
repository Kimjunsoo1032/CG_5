Shader "Unlit/08_Normal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex ("NormalTex", 2D) = "bump" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Ambient ("Ambient", Range(0,1)) = 0.2
        _SpecColor ("SpecColor", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(1,256)) = 32
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
                float4 vertex  : POSITION;
                float2 uv      : TEXCOORD0;
                float3 normal  : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                float3 normal   : TEXCOORD1;
                float3 tangent  : TEXCOORD2;
                float3 binormal : TEXCOORD3;

                float3 wPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _NormalTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float  _Ambient;
            fixed4 _SpecColor;
            float  _Shininess;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 n = normalize(v.normal);
                float3 t = normalize(v.tangent.xyz);
                float3 b = normalize(cross(n, t) * v.tangent.w * unity_WorldTransformParams.w);

                o.normal = n;
                o.tangent = t;
                o.binormal = b;

                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;

                float3 nMap = tex2D(_NormalTex, i.uv).xyz * 2.0 - 1.0;
                nMap = normalize(nMap);

                float3 t = normalize(i.tangent);
                float3 b = normalize(i.binormal);
                float3 n = normalize(i.normal);

                float3 lNormal = normalize(t * nMap.x + b * nMap.y + n * nMap.z);
                float3 wNormal = normalize(UnityObjectToWorldNormal(lNormal));

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir  = normalize(_WorldSpaceCameraPos.xyz - i.wPos);

                float ndl = saturate(dot(wNormal, lightDir));

                fixed3 ambient  = albedo.rgb * _Ambient;
                fixed3 diffuse  = albedo.rgb * ndl;

                float3 h = normalize(lightDir + viewDir);
                float specPow = pow(saturate(dot(wNormal, h)), _Shininess);
                fixed3 specular = _SpecColor.rgb * specPow;

                fixed4 col = fixed4(ambient + diffuse + specular, albedo.a);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
