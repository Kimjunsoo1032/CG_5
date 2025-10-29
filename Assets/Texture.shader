Shader "Unlit/Texture" 
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color   ("Color", Color) = (1,1,1,1)
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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;  
                float3 normal : NORMAL;     
            };

            struct v2f
            {
                float4 vertex        : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float3 worldPosition : TEXCOORD1; 
                float3 worldNormal   : NORMAL;    
            };

            sampler2D _MainTex;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex        = UnityObjectToClipPos(v.vertex);
                o.uv            = v.uv;
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal   = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 ambient = _Color * 0.3 * _LightColor0;
                return col * ambient;
            }
            ENDCG
        }
    }
}