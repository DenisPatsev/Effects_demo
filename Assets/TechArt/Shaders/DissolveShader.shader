Shader "Custom/DissolveShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [HDR] _MainColor("Main Color", Color) = (1,1,1,1)
        _DissolveSpeed("Dissolve Speed", Range(0, 20)) = 1
        _DissolveThreshold("Color Threshold", Range(0, 1)) = 0.1
        _BorderWidth("Border Width", Range(0, 0.1)) = 0.1
        [HDR]_BorderColor("Border Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BorderColor, _MainColor;
            half _DissolveSpeed;
            half _DissolveThreshold;
            half _BorderWidth;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                float deltaTime = _Time.x * _DissolveSpeed;
                float4 threshold = col - (_DissolveThreshold + deltaTime);
                clip(threshold);
                float glow = smoothstep(_BorderWidth, 0, threshold);
                col += glow * _BorderColor;
                return col;
            }
            ENDCG
        }
    }
}