Shader "Custom/FakeWater"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [NoScaleOffset] _FlowMap("Flow (RG, A noise)", 2D) = "black"{}
        [NoScaleOffset] _DeriveHeightMap("Derive Height", 2D) = "black"{}
        _UJump("U jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump("V jump per phase", Range(-0.25, 0.25)) = 0.25
        _Tiling("Tiling", float) = 1
        _Speed("Speed", Range(0, 2)) = 1
        _FlowStrength("FlowStrength", Range(-3, 3)) = 1
        _FlowOffset("FlowOffset", Range(-3, 3)) = 1
        _HeightScale("Height map scale, Constant", Range(0, 1)) = 0.25
        _HeightScaleModulated("Height map scale, Modulated", Range(0, 1)) = 0.75
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex, _FlowMap, _DeriveHeightMap;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset, _HeightScale, _HeightScaleModulated;
        fixed4 _Color;

        float3 UnpackRerivativeHeight(float4 textureData)
        {
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 - 1;
            return dh;
        }

        float3 FLowUVW(float2 uv, float2 flowVector, float2 jump, float2 tiling , float flowOffset, float time, bool flowB)
        {
            float phaseOffset = flowB ? 0.5 : 0;
            float progress = frac(time + phaseOffset);
            float3 uvw;
            uvw.xy = uv - flowVector * (progress + flowOffset);
            uvw.xy *= tiling;
            uvw.xy += phaseOffset;
            uvw.xy += (time - progress) * jump;
            uvw.z = 1 - abs(1 - 2 * progress);
            return uvw;
        }

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 flow = tex2D(_FlowMap, IN.uv_MainTex).rgb;
            flow.xy = flow.xy * 2 - 1;
            flow *= _FlowStrength;
            
            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
            float time = _Time.y * _Speed + noise;
            float jump = float2(_UJump, _VJump);

            float3 uvwA = FLowUVW(IN.uv_MainTex, flow.xy, jump, _Tiling, _FlowOffset, time, false);
            float3 uvwB = FLowUVW(IN.uv_MainTex, flow.xy, jump, _Tiling, _FlowOffset, time, true);

            float finalHeightScale = length(flow.z) * _HeightScaleModulated + _HeightScale;

            float3 dhA = UnpackRerivativeHeight(tex2D(_DeriveHeightMap, uvwA.xy)) * (uvwA.z * finalHeightScale);
            float3 dhB = UnpackRerivativeHeight(tex2D(_DeriveHeightMap, uvwB.xy)) * (uvwB.z * finalHeightScale);
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy), 1)); 

            fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
            fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

            fixed4 c = (texA + texB) * _Color;

            o.Albedo = c;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}