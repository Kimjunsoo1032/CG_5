Shader "Unlit/Texture"
{
    Properties { 
        _Color("Color",Color) = (1,1,1,1)
        _MainTex ("Texture",2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f {
                float4 vertex        : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal   : TEXCOORD1;
                float2 uv            : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex        = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal   = UnityObjectToWorldNormal(v.normal);
                o.uv            = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv) * _Color;
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0); 
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPosition);

                fixed4 ambient = texCol * 0.3 * _LightColor0;
                float  intensity = saturate(dot(N, L));
                fixed4 diffuse   = texCol * intensity * _LightColor0;
                float3 R = reflect(-L, N);
                fixed4 specular  = pow(saturate(dot(R, V)), 20) * _LightColor0;

                return ambient + diffuse + specular;
            }
            ENDCG
        }
    }
}