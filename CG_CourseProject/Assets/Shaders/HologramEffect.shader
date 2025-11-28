Shader "URP/CellShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (0.3, 0.3, 0.3, 1)
        _Bands ("Shading Bands", Range(1, 10)) = 3
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.03
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _TextureScale ("Texture Scale", Float) = 1.0
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Name "CellShading"
            Cull Back
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 positionOS : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            float4 _Color;
            float4 _ShadowColor;
            float _Bands;
            float _TextureScale;
            float _NormalStrength;

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);
                o.positionOS = v.positionOS.xyz;
                return o;
            }

            half3 TriplanarSample(float3 posOS, float3 normalOS, float scale)
            {
                float3 blend = abs(normalOS);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = posOS.yz * scale;
                float2 uvY = posOS.xz * scale;
                float2 uvZ = posOS.xy * scale;

                half3 sampleX = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvZ).rgb;

                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }

            half3 TriplanarNormal(float3 posOS, float3 normalOS, float3 normalWS, float scale)
            {
                float3 blend = abs(normalOS);
                blend = pow(blend, 4);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = posOS.yz * scale;
                float2 uvY = posOS.xz * scale;
                float2 uvZ = posOS.xy * scale;

                half3 normalX = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvX));
                half3 normalY = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvY));
                half3 normalZ = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvZ));

                normalX = half3(normalX.x, normalX.z, normalX.y);
                normalY = half3(normalY.x, normalY.y, normalY.z);
                normalZ = half3(normalZ.x, normalZ.y, normalZ.z);

                half3 blendedNormal = normalX * blend.x + normalY * blend.y + normalZ * blend.z;
                blendedNormal = normalize(normalWS + blendedNormal * _NormalStrength);
                
                return blendedNormal;
            }

            half4 frag(Varyings i) : SV_Target
            {
                if (_TextureScale < 0.001)
                    return half4(0.2, 0.2, 0.2, 1.0);
                
                float3 normalOS = normalize(mul((float3x3)unity_WorldToObject, i.worldNormal));
                half3 texColor = TriplanarSample(i.positionOS, normalOS, _TextureScale);
                
                float3 normal = TriplanarNormal(i.positionOS, normalOS, i.worldNormal, _TextureScale);
                
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                
                float NdotL = dot(normal, -lightDir);
                NdotL = (NdotL + 1.0) * 0.5;
                
                float bandStep = 1.0 / _Bands;
                float bandedLight = floor(NdotL / bandStep) * bandStep;
                
                half3 litColor = lerp(_ShadowColor.rgb, _Color.rgb, bandedLight);
                half3 finalColor = texColor * litColor;
                
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            Varyings vert(Attributes v)
            {
                Varyings o;
                float3 normal = TransformObjectToWorldNormal(v.normalOS);
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                positionWS += normal * _OutlineWidth;
                o.positionHCS = TransformWorldToHClip(positionWS);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}