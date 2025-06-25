Shader "Custom/Unlit/CutoutUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color("Color", Color) = (1,1,1,1)
        _AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0
        _Transparency("Transparency", Range(0, 1)) = 1
        _Emission("Emission", Range(0, 3)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjection" = "True"
            
        }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        ZWrite Off
        Lighting Off

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex, _MaskTex;
            float _AlphaCutoff, _MaskCutout;
            float _Transparency;
            float4 _MainTex_ST;
            float4 _Color, _MaskColor;
            float _Emission;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v)
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                clip(col - _AlphaCutoff);
                col.a *= _Transparency;
                col *= _Emission;
                return col;
            }
            ENDCG
        }
    }
}