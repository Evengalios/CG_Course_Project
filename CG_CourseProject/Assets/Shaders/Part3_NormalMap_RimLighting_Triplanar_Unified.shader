Shader "URP/Part3_Triplanar_NormalMap_RimLighting_Unified"
{
    Properties
    {
        [Header(BASE)]
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Color ("Color (Albedo Tint)", Color) = (1,1,1,1)
        [HDR] _RimColor ("Rim Color", Color) = (0,1,1,1)
        _TextureScale ("Texture Scale", Float) = 1.0

        [Header(LIGHTING)]
        _AmbientFactor ("Ambient Factor (Used in Mode 5)", Range(0,1)) = 0.5 
        _DiffuseWrapAmount ("Diffuse Wrap Amount (Used in Mode 5)", Range(0,1)) = 0.7 
        _SpecularStrength ("Specular Strength", Range(0,1)) = 0.5
        _Shininess ("Shininess", Range(1,128)) = 32
        
        [Header(RIM_AND_NORMAL)]
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _RimPower ("Rim Power", Range(0.1, 10)) = 3
        _RimIntensity ("Rim Intensity", Range(0, 5)) = 1

        [Header(MODE_SWITCH)]
        [IntRange] _Mode ("Lighting Mode (0:Albedo Only, 1:Diffuse, 2:Ambient, 3:Specular, 5:Original Look+Spec)", Range(0, 5)) = 5
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 localPos    : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float3 tangentWS   : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 worldPos    : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            float4 _Color;
            float4 _RimColor;
            float _AmbientFactor;
            float _DiffuseWrapAmount;
            float _SpecularStrength;
            float _Shininess;
            float _RimPower;
            float _RimIntensity;
            float _NormalStrength;
            float _TextureScale;
            int _Mode;

            Varyings vert(Attributes v)
            {
                Varyings o;
                
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.localPos = v.positionOS.xyz;
                o.worldPos = TransformObjectToWorld(v.positionOS.xyz);

                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.tangentWS = TransformObjectToWorldDir(v.tangentOS.xyz);
                o.bitangentWS = cross(o.normalWS, o.tangentWS) * v.tangentOS.w;
                
                return o;
            }

            half3 TriplanarObjectSample(TEXTURE2D(tex), SAMPLER(samplerTex), float3 localPos, float3 normal)
            {
                float3 blend = abs(normal);
                blend = pow(blend, 4.0);
                blend /= (blend.x + blend.y + blend.z + 1e-5);
                
                float2 uvX = localPos.yz * _TextureScale;
                float2 uvY = localPos.xz * _TextureScale;
                float2 uvZ = localPos.xy * _TextureScale;
                
                half3 sampleX = SAMPLE_TEXTURE2D(tex, samplerTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(tex, samplerTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(tex, samplerTex, uvZ).rgb;
                
                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }
            
            half3 TriplanarNormalSample(float3 localPos, float3 normal)
            {
                half3 normalSample = TriplanarObjectSample(_NormalMap, sampler_NormalMap, localPos, normal);
                
                normalSample = normalSample * 2.0 - 1.0;
                normalSample.xy *= _NormalStrength;
                
                return normalize(normalSample); 
            }

            half4 frag(Varyings i) : SV_Target
            {
                float3 normalWS = normalize(i.normalWS);
                float3 tangentWS = normalize(i.tangentWS);
                float3 bitangentWS = normalize(i.bitangentWS);
                
                half3 normalTangent = TriplanarNormalSample(i.localPos, normalWS);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
                float3 normal = normalize(mul(normalTangent, TBN));
                
                half3 albedo = TriplanarObjectSample(_MainTex, sampler_MainTex, i.localPos, normalWS) * _Color.rgb;

                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 halfDir = normalize(-lightDir + viewDir);

                half NdotL_Standard = saturate(dot(normal, -lightDir));
                half NdotH = saturate(dot(normal, halfDir));
                
                half3 diffuse_standard = albedo * mainLight.color * NdotL_Standard;
                half3 ambient_standard = albedo * SampleSH(normal) * _AmbientFactor;
                half3 specular = mainLight.color * pow(NdotH, _Shininess) * _SpecularStrength;

                half NdotL_OriginalWrap = saturate(dot(normal, lightDir)) * _DiffuseWrapAmount + (1.0 - _DiffuseWrapAmount);
                half3 diffuse_original = albedo * mainLight.color * NdotL_OriginalWrap;
                half3 ambient_original = albedo * SampleSH(normal) * _AmbientFactor;

                half rim = 1.0 - saturate(dot(normal, viewDir));
                rim = pow(rim, _RimPower);
                half3 rimLight = _RimColor.rgb * rim * _RimIntensity;
                
                half3 finalColor = albedo;

                if (_Mode == 1)
                {
                    finalColor = diffuse_standard;
                }
                else if (_Mode == 2)
                {
                    finalColor = ambient_standard;
                }
                else if (_Mode == 3)
                {
                    finalColor = albedo * 0.3 + specular;
                }
                else if (_Mode == 4)
                {
                    finalColor = diffuse_standard + ambient_standard;
                }
                else if (_Mode == 5)
                {
                    // MODE 5: Original Look (Wrap Diffuse + Ambient Factor + Specular)
                    finalColor = diffuse_original + ambient_original + specular;
                }
                // Mode 0: finalColor = albedo (texture only)
                
                // Add Rim Lighting to all modes except Mode 0 (Albedo Only)
                if (_Mode > 0)
                {
                    finalColor += rimLight;
                }
                
                return half4(finalColor, _Color.a);
            }

            ENDHLSL
        }
    }
}