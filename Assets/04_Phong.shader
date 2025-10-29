Shader "Unlit/04_Phong"
{
    Properties { _Color("Color",Color) = (1,1,1,1) }

    SubShader
    {
        Pass
        {
            // Tags{ "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex        : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal   : TEXCOORD1;
            };

            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex        = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal   = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 ambient = _Color * 0.3 * _LightColor0;
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0);
                float  intensity = saturate(dot(N, L));
                fixed4 diffuse   = _Color * intensity * _LightColor0;
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 R = reflect(-L, N);
                fixed4 specular = pow(saturate(dot(R, V)), 20) * _LightColor0;
                fixed4 phong = ambient + diffuse + specular;
                return phong;
            }
            ENDCG
        }
    }
}