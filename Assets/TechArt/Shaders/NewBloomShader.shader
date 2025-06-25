Shader "Unlit/NewBloomShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomIntensity("Bloom intensity", Range(0,10)) = 1.0
        _BloomOffset("Bloom offset", Range(0, 5)) = 1.0
        _BloomThreshold("Bloom Threshold", Range(0, 10)) = 0
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _SourceTex;
    half _Threshold;
    half _Intensity;
    float4 _MainTex_TexelSize;

    struct VertexData
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct Interpolators
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    Interpolators VertexProgram(VertexData v)
    {
        Interpolators i;
        i.pos = UnityObjectToClipPos(v.vertex);
        i.uv = v.uv;
        return i;
    }

    half3 Sample(float2 uv)
    {
        return tex2D(_MainTex, uv).rgb;
    }

    half3 SampleBox(float2 uv, float delta)
    {
        float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
        half3 s = Sample(uv + o.xy) + Sample(uv + o.zy) +
            Sample(uv + o.xw) + Sample(uv + o.zw);
        return s * 0.25f;
    }

    half3 Prefilter(half3 c)
    {
        half brightness = max(c.r, max(c.g, c.b));
        half contribution = max(0, brightness - _Threshold);
        contribution /= max(brightness, 0.00001);
        return c * contribution;
    }
    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            half4 FragmentProgram(Interpolators i) : SV_Target
            {
                return half4(Prefilter(SampleBox(i.uv, 1)), 1);
            }
            ENDCG

        }

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            half4 FragmentProgram(Interpolators i) : SV_Target
            {
                return half4(SampleBox(i.uv, 1), 1);
            }
            ENDCG

        }

        Pass
        {
            Blend One One

            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            half4 FragmentProgram(Interpolators i) : SV_Target
            {
                return half4(SampleBox(i.uv, 0.5), 1);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            half4 FragmentProgram(Interpolators i) : SV_Target
            {
                half4 col = tex2D(_SourceTex, i.uv);
                col.rgb += SampleBox(i.uv, 0.5) * _Intensity;
                return col;
            }
            ENDCG
        }
    }
}