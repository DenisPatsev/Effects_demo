Shader "Custom/Unlit/NatureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0, 1)) = 1.0
//        _Glossiness("Glossiness", Range(0, 1)) = 0
//        _Metallic("Metallic", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="TransparentCutout"
            "Queue" = "AlphaTest"
            "IgnoreProjector" = "True"
        }
        LOD 100

        Cull Off
        ZTest LEqual
        ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _Color;
            
            // UNITY_INSTANCING_BUFFER_START(Props)
            //     UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _Transparency)
            // UNITY_INSTANCING_BUFFER_END(Props)
    
            // float4 _Color;
            float4 _MainTex_ST;
            float _Transparency;

            v2f vert(appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v)
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                // UNITY_TRANSFER_INSTANCE_ID(v, o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                // UNITY_SETUP_INSTANCE_ID(i);
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                clip(col.a - _Transparency);
                UNITY_APPLY_FOG(i.fogCoord, col);
                // clip(col.a - UNITY_ACCESS_INSTANCED_PROP(Props, _Transparency));
                // return col * UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                return col;
            }
            ENDCG
        }
    }
}