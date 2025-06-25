Shader "Custom/Unlit/CustomUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color("Color", Color) = (1, 1, 1, 1)
        _MetallicGlossMap("Metallic Map", 2D) = "white"{}
        _Metallic("Metallic Power", Range(0, 2)) = 0
        _LightDir("Light direction", Vector) = (1, 1, 1)
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Normal scale", Float) = 1.0
        [HDR]_EmissionColor("Emission Color", Color) = (1,1,1,1)
        _EmissionIntensity("EmissionIntensity", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWorld : TEXCOORD1;
                float3 tangentWorld : TEXCOORD2;
                float3 binormalWorld : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };

            sampler2D _MainTex;
            sampler2D _OcclusionMap;
            sampler2D _MetallicGlossMap;
            sampler2D _BumpMap;
            float4 _MainTex_ST;
            float4 _EmissionColor;
            float4 _Color;
            float3 _LightDir;
            float _EmissionIntensity;
            float _OcclusionStrength;
            float _Metallic;
            float _BumpScale;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v)
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
                o.binormalWorld = cross(o.normalWorld, o.tangentWorld) * v.tangent.w;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                float metallic = tex2D(_MetallicGlossMap, i.uv).r * _Metallic;
                float3 normalMap = UnpackNormal(tex2D(_BumpMap, i.uv.xy));
                normalMap.xy *= _BumpScale;

                float3 normalWorld = normalize(
                    normalMap.x * i.tangentWorld +
                    normalMap.y * i.binormalWorld +
                    normalMap.z * i.normalWorld
                );

                float4 emission = _EmissionColor * _EmissionIntensity;
                float3 fakeLightDir = normalize(_LightDir);
                float ndotl = dot(normalWorld, fakeLightDir) * 0.5 + 0.5;
                col.rgb *= ndotl;
                col.rgb *= metallic;
                col += emission;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}