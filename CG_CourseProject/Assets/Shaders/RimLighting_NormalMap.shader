Shader "URP/RimLighting_NormalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Color ("Color", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (0,1,1,1)
        _RimPower ("Rim Power", Range(0.1, 10)) = 3
        _RimIntensity ("Rim Intensity", Range(0, 5)) = 1
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _TextureScale ("Texture Scale", Float) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };
            
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            float4 _Color;
            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;
            float _NormalStrength;
            float _TextureScale;
            
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
                blend = pow(blend, 4);
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
                float3 normal = normalize(i.normalWS);
                float3 tangent = normalize(i.tangentWS);
                float3 bitangent = normalize(i.bitangentWS);
                
                half3 normalTangent = TriplanarNormalSample(i.localPos, normal);
                
                float3x3 TBN = float3x3(tangent, bitangent, normal);
                normal = normalize(mul(normalTangent, TBN));
                
                half3 tex = TriplanarObjectSample(_MainTex, sampler_MainTex, i.localPos, normal) * _Color.rgb;
                
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                half NdotL = saturate(dot(normal, lightDir)) * 0.7 + 0.3;
                half3 diffuse = tex * mainLight.color * NdotL;
                
                half3 ambient = tex * SampleSH(normal) * 0.5;
                
                half rim = 1.0 - saturate(dot(normal, viewDir));
                rim = pow(rim, _RimPower);
                half3 rimLight = _RimColor.rgb * rim * _RimIntensity;
                
                half3 finalColor = diffuse + ambient + rimLight;
                
                return half4(finalColor, _Color.a);
            }
            ENDHLSL
        }
    }
}