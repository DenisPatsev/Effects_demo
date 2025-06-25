Shader "Custom/Unlit/ContructionShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [HDR] _MainColor("Main color", Color) = (1,1,1,1)
        _MaskTex ("Mask Texture", 2D) = "white" {}
        [HDR] _MaskColor("Mask Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0, 1)) = 1
        _EmissionIntensity("EmissionIntensity", Range(1, 2)) = 1
        _VertexPosCutoff("Vertex Position Cutoff", Range(-0.015, 0.015)) = 0.015
        _CutoffSpeed("Cutoff speed", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        Cull Back
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            Name "MAIN"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localVert : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainColor)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MaskColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _EmissionIntensity)
                UNITY_DEFINE_INSTANCED_PROP(float, _Transparency)
            UNITY_INSTANCING_BUFFER_END(Props)

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _VertexPosCutoff;
            float _CutoffSpeed;
            float _DynamicCutoff;
            float _DeltaTime;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST);
                o.uv = v.uv * mainTexST.xy + mainTexST.zw;
                o.localVert = v.vertex;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                // _DynamicCutoff = _VertexPosCutoff - _DeltaTime * _CutoffSpeed;
                clip(i.localVert.y - _VertexPosCutoff);

                fixed4 col = tex2D(_MaskTex, i.uv) * UNITY_ACCESS_INSTANCED_PROP(Props, _MaskColor);
                col.rgb *= UNITY_ACCESS_INSTANCED_PROP(Props, _EmissionIntensity);
                col.a *= UNITY_ACCESS_INSTANCED_PROP(Props, _Transparency);

                return col;
            }
            ENDCG
        }
    }
}