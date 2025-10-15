Shader "Unlit/03_Specular"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        // LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 worldNormal : NORMAL;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal   = UnityObjectToWorldNormal(v.normal);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
               float3 lightDir = normalize(_WorldSpaceLightPos0);
               i.worldNormal = normalize(i.worldNormal);  
               float3 reflectDir = -lightDir + 2 * i.worldNormal * dot(i.worldNormal, lightDir);
               fixed4 specular = pow(saturate(dot(reflectDir,eyeDir)),20)*_LightColor0;
               return specular;
            }
            ENDCG
        }
    }
}
