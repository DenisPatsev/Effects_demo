Shader "Custom/NatureSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha cutoff", Range(0, 1)) = 1.0
        _BumpMap("Bump Map", 2D) = "bump"{}
        _NormalScale("Normal map scale", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "IgnoreProjector" = "True"
        }
        LOD 100

        Cull Off
        ZTest LEqual
        ZWrite On

        CGPROGRAM
        #pragma surface surf Lambert addshadow nometa
        #pragma multi_compile_shadowcaster

        sampler2D _MainTex, _BumpMap;
        float _NormalScale, _Cutoff;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
            float3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex)).rgb;
            normal.xy *= _NormalScale;
            normal = normalize(normal);
            clip(c.a - _Cutoff);
            o.Alpha = c.a;
            o.Normal = normal;
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}