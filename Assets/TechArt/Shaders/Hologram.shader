Shader "Custom/Unlit/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HologramTex("HologramTexture", 2D) = "white" {}
        _MainColor("ImageColor", Color) = (0, 1, 0, 1)
        _Color("Hologram", Color) = (0, 1, 0, 1)
        _Transparency("Transparency", Range(0, 1)) = 1
        _ScrollSpeed("Scroll Speed", Range(0, 5)) = 1
        _NoiseScale("NoiseScale", Range(0, 0.5)) = 1
        _NoiseSize("NoiseSize", Range(0,400)) = 0.2
        _FresnelPower("FresnelPower", Range(0, 10)) = 1
        _FresnelIntensity("FresnelIntensity", Range(0, 20)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
            "IgnoreProjection" = "true"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _HologramTex;
            float4 _MainTex_ST;
            float4 _HologramTex_ST;
            float4 _Color, _MainColor;
            float _Transparency, _ScrollSpeed, _NoiseScale, _NoiseSize, _FresnelPower, _FresnelIntensity;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _HologramTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 pixelatedUV = floor(i.uv * _NoiseSize) / _NoiseSize;
                float randomValue = rand(pixelatedUV) * _NoiseScale;
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;

                float fresnel = dot(i.worldNormal, i.viewDir);
                fresnel = saturate(1 - fresnel);
                fresnel = pow(fresnel, _FresnelPower);

                col = lerp(col, _Color, randomValue);
                fixed2 maskUV = i.uv2 + fixed2(0, _Time.y * _ScrollSpeed);
                fixed4 mask = tex2D(_HologramTex, maskUV) * _Color;
                col += mask;
                col += fresnel * _FresnelIntensity * _Color;
                col.a = _Transparency;
                return col;
            }
            ENDCG
        }
    }
}