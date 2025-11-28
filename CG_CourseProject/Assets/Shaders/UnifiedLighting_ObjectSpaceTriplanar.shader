Shader "URP/UnifiedLighting_ObjectSpaceTriplanar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Height/Bump Map", 2D) = "bump" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0,1)) = 0.4
        _SpecularStrength ("Specular Strength", Range(0,1)) = 0.5
        _Shininess ("Shininess", Range(1,128)) = 32
        _TextureScale ("Texture Scale", Float) = 1.0
        _Mode ("Lighting Mode", Int) = 5
        _BumpStrength ("Bump Strength", Float) = 1.0
        _BlendSharpness ("Blend Sharpness", Range(1,16)) = 4.0
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
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionOS : TEXCOORD2; 
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            float4 _Color;
            float _AmbientStrength;
            float _SpecularStrength;
            float _Shininess;
            float _TextureScale;
            int _Mode;
            float _BumpStrength;
            float _BlendSharpness;
   
            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionOS = v.positionOS.xyz;  
                o.worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.positionHCS = TransformWorldToHClip(o.worldPos);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            half3 TriplanarObjectSpace(TEXTURE2D(tex), SAMPLER(samplerTex), float3 posOS, float3 normalOS, float scale)
            {
                float3 blend = abs(normalOS);
                blend = pow(blend, _BlendSharpness);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = posOS.zy * scale;
                float2 uvY = posOS.xz * scale;
                float2 uvZ = posOS.xy * scale;

                half3 sampleX = SAMPLE_TEXTURE2D(tex, samplerTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(tex, samplerTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(tex, samplerTex, uvZ).rgb;

                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }

            half3 TriplanarBumpObjectSpace(float3 posOS, float3 normalOS, float3 normalWS, float scale)
            {
                float3 blend = abs(normalOS);
                blend = pow(blend, _BlendSharpness);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = posOS.zy * scale;
                float2 uvY = posOS.xz * scale;
                float2 uvZ = posOS.xy * scale;

                half3 bumpX = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvX).rgb;
                half3 bumpY = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvY).rgb;
                half3 bumpZ = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uvZ).rgb;

                bumpX = (bumpX * 2 - 1) * _BumpStrength;
                bumpY = (bumpY * 2 - 1) * _BumpStrength;
                bumpZ = (bumpZ * 2 - 1) * _BumpStrength;

                half3 bump = bumpX * blend.x + bumpY * blend.y + bumpZ * blend.z;
                
                return normalize(normalWS + bump);
            }

            half4 frag(Varyings i) : SV_Target
            {
                float3 normalOS = normalize(mul((float3x3)unity_WorldToObject, i.normalWS));
                
                half3 normal = normalize(i.normalWS);
                normal = TriplanarBumpObjectSpace(i.positionOS, normalOS, normal, _TextureScale);
                half3 tex = TriplanarObjectSpace(_MainTex, sampler_MainTex, i.positionOS, normalOS, _TextureScale) * _Color.rgb;

                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                half3 finalColor = tex;

                if (_Mode == 1)
                {
                    half NdotL = saturate(dot(normal, -lightDir));
                    finalColor = tex * mainLight.color * NdotL;
                }
                else if (_Mode == 2)
                {
                    finalColor = tex * SampleSH(normal) * _AmbientStrength;
                }
                else if (_Mode == 3)
                {
                    half3 halfDir = normalize(-lightDir + viewDir);
                    half NdotH = saturate(dot(normal, halfDir));
                    half3 specular = mainLight.color * pow(NdotH, _Shininess) * _SpecularStrength;
                    finalColor = tex * 0.3 + specular;
                }
                else if (_Mode == 4)
                {
                    half NdotL = saturate(dot(normal, -lightDir));
                    half3 diffuse = tex * mainLight.color * NdotL;
                    half3 ambient = tex * SampleSH(normal) * _AmbientStrength;
                    finalColor = diffuse + ambient;
                }
                else if (_Mode == 5)
                {
                    half NdotL = saturate(dot(normal, -lightDir));
                    half3 diffuse = tex * mainLight.color * NdotL;
                    half3 ambient = tex * SampleSH(normal) * _AmbientStrength;
                    half3 halfDir = normalize(-lightDir + viewDir);
                    half NdotH = saturate(dot(normal, halfDir));
                    half3 specular = mainLight.color * pow(NdotH, _Shininess) * _SpecularStrength;
                    finalColor = diffuse + ambient + specular;
                }

                return half4(finalColor, _Color.a);
            }

            ENDHLSL
        }
    }
}