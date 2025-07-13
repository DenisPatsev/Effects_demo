Shader "Custom/FresnelEffect"
{
    Properties
    {
        [HDR] _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _FresnelPower("Fresnel Power", Range(0, 10)) = 1
        [HDR] _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard nometa alpha:fade

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic, _FresnelPower;
        fixed4 _Color, _FresnelColor;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            float fresnel = dot(IN.worldNormal, IN.viewDir);
            fresnel = saturate(1 - fresnel);
            fresnel += pow(fresnel, _FresnelPower);

            _FresnelColor *= fresnel;
            o.Smoothness = _Glossiness;
            o.Metallic = _Metallic;
            o.Emission += _FresnelColor * fresnel;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}