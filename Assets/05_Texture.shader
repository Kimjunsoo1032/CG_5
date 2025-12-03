Shader "Unlit/05_Texture"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _SubTex  ("SubTex",  2D) = "white" {} 
        _MaskTex ("MaskTex", 2D) = "black" {}  

        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(1,128)) = 32
        _LightDir  ("Light Direction", Vector) = (0,1,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex      : SV_POSITION;
                float2 uvMain      : TEXCOORD0;
                float2 uvSub       : TEXCOORD1;
                float2 uvMask      : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldPos    : TEXCOORD4;
            };

            sampler2D _MainTex;  
            sampler2D _SubTex;   
            sampler2D _MaskTex; 

            float4 _MainTex_ST;
            float4 _SubTex_ST;
            float4 _MaskTex_ST;

            float4 _SpecColor;
            float  _Shininess;
            float4 _LightDir;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex  = UnityObjectToClipPos(v.vertex);

                o.uvMain  = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSub   = TRANSFORM_TEX(v.uv, _SubTex);
                o.uvMask  = TRANSFORM_TEX(v.uv, _MaskTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos    = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 main = tex2D(_MainTex, i.uvMain);
                fixed4 sub  = tex2D(_SubTex,  i.uvSub);
                fixed4 mask = tex2D(_MaskTex, i.uvMask);
            
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_LightDir.xyz);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 H = normalize(L + V);
            
                float specPow   = pow(max(dot(N, H), 0.0), _Shininess);
                float3 specular = _SpecColor.rgb * specPow;
                specular *= mask.r;
            
                return fixed4(specular, 1);
            }
            ENDCG
        }
    }
}