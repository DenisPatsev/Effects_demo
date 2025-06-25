Shader "Custom/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FarColor("Far color", Color) = (1,1,1,1)
        _DepthFactor("Depht Factor", float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _CAMERA_DEPTH_TEXTURE

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
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _FarColor;
            float _DepthFactor;

            fixed4 frag(v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth);
                float4 col = tex2D(_MainTex, i.uv);

                float fogFactor = saturate(depth * _DepthFactor);
                float4 finalColor = lerp(col, _FarColor, fogFactor);
                return finalColor;
            }
            ENDCG
        }
    }
}