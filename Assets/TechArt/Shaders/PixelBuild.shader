Shader "Custom/PixelBuildEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelSize ("Pixel Size", Range(1, 200)) = 10
        _BuildProgress ("Build Progress", Range(0, 1)) = 0
        _EdgeSmoothness ("Edge Smoothness", Range(0.01, 0.5)) = 0.1
        _BaseColor ("Base Color", Color) = (1,1,1,1)
      [HDR] _PixelColor ("Pixel Color", Color) = (0.5,0.5,0.5,1)
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PixelSize;
            float _BuildProgress;
            float _EdgeSmoothness;
            float4 _BaseColor;
            float4 _PixelColor;
            float _BackgroundAlpha;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 pixelatedUV = floor(i.uv * _PixelSize) / _PixelSize;
                
                float randomValue = rand(pixelatedUV);
                
                float pixelVisibility = smoothstep(
                    _BuildProgress - _EdgeSmoothness,
                    _BuildProgress + _EdgeSmoothness,
                    randomValue
                );
                
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 col = lerp(fixed4(_PixelColor.rgb, 1), fixed4(texColor.rgb * _BaseColor.rgb, 1.0), pixelVisibility);

                clip(randomValue - _BuildProgress);
                
                return col;
            }
            ENDCG
        }
    }
}