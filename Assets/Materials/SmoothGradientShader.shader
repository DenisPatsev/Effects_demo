Shader "Custom/Unlit/SmoothGradientShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main color", Color) = (1,1,1,1)
        [HDR] _EmissionColor("Emission color", Color) = (1,1,1,1)
        _EmissionIntensity("Emission intensity", Range(0, 2)) = 0.1
        _Transparency("Transparency", Range(0, 1)) = 0
        _Radius("Radius", Range(0, 0.3)) = 0
        _CircleSmoothness("Circle smoothness", Range(0, 0.4)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
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
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color :COLOR;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor, _EmissionColor;
            float _EmissionIntensity;
            float _Transparency, _Radius, _CircleSmoothness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color * _EmissionColor;
                float2 uv = i.uv - 0.5;
                float distance = length(pow(uv, 3));
                float delta = smoothstep(_Radius - _CircleSmoothness, _Radius + _CircleSmoothness, distance);
                col.rgb = lerp(_EmissionColor, i.color * _EmissionIntensity, delta);
                col *= _EmissionIntensity;
                col *= i.color;
                col.a *= _Transparency;
                return col;
            }
            ENDCG
        }
    }
}
