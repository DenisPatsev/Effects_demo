Shader "Custom/MaskShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [HDR] _MainColor("Main color", Color) = (1,1,1,1)
        _MaskTex ("Mask Texture", 2D) = "white" {}
        [HDR] _MaskColor("Mask Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0, 1)) = 1
        _BumpMap("Normal map", 2D) = "bump"{}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "AlphaTest"
        }
        LOD 100
        Cull Back
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWorld : TEXCOORD1;
                float3 tangentWorld : TEXCOORD2;
                float3 binormalWorld : TEXCOORD3;
            };

            sampler2D _MainTex, _BumpMap;
            float4 _MainTex_ST;
            float4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
                o.binormalWorld = cross(o.normalWorld, o.tangentWorld) * v.tangent.w;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                float3 fakeLightDir = normalize(float3(0.5, 1, 0.3));
                float3 normalMap = UnpackNormal(tex2D(_BumpMap, i.uv.xy));

                float3 normalWorld = normalize(
                    normalMap.x * i.tangentWorld +
                    normalMap.y * i.binormalWorld +
                    normalMap.z * i.normalWorld
                );

                float ndotl = dot(normalWorld, fakeLightDir) * 0.5 + 0.5;
                col.rgb *= ndotl;
                return col;
            }
            ENDCG
        }

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _MaskColor;
            float _Transparency;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_MaskTex, i.uv) * _MaskColor;
                mask.a *= _Transparency;
                return mask;
            }
            ENDCG
        }
    }
}