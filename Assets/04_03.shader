Shader "Unlit/04_03"
{
    Properties
    {
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0, 1)) = 0
        _FrontColor ("Front Color", Color) = (0, 1, 1, 1)
        _BackColor ("Back Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        CGINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        sampler2D _MaskTex;
        float4 _MaskTex_ST;
        float _Dissolve;
        float4 _FrontColor;
        float4 _BackColor;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MaskTex);
            return o;
        }
        ENDCG

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Cull front
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex, i.uv);
                clip(mask.r - _Dissolve);
                return _FrontColor;
            }
            ENDCG
        }

        Pass
        {
            Cull back
            CGPROGRAM
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex, i.uv);
                clip(mask.r - _Dissolve);
                return lerp(_BackColor, mask, mask.a);
            }
            ENDCG
        }
    }
}