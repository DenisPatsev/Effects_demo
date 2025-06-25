Shader "Hidden/VIgnete"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Vignete color", Color) = (0,0,0,0)
        _VigneteSize("Vignete size", Range(0, 5)) = 1.0
        _VigneteSmoothness("Vignette smoothness", Range(0,5)) = 1.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
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
            fixed4 _Color;
            float _VigneteSize;
            float _VigneteSmoothness;
            

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 uv = i.uv - 0.5;
                float distance = length(uv);
                col = lerp(col, _Color, distance * _VigneteSize * _VigneteSmoothness);
                return col;
            }
            ENDCG
        }
    }
}