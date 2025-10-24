Shader "URP/Part2_UnifiedLighting"
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
   
            Varyings vert(Attributes v)
            {
                Varyings o;
                o.worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.positionHCS = TransformWorldToHClip(o.worldPos);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            float3 RotateX(float3 pos, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float3(pos.x, c*pos.y - s*pos.z, s*pos.y + c*pos.z);
            }

            float3 RotateY(float3 pos, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float3(c*pos.x + s*pos.z, pos.y, -s*pos.x + c*pos.z);
            }

            half3 TriplanarSample(TEXTURE2D(tex), SAMPLER(samplerTex), float3 worldPos, float3 normal, float scale)
            {
                float3 pos = RotateX(worldPos, radians(10));
                pos = RotateY(pos, radians(10));

                float3 blend = abs(normal);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = pos.yz * scale;
                float2 uvY = pos.xz * scale;
                float2 uvZ = pos.xy * scale;

                half3 sampleX = SAMPLE_TEXTURE2D(tex, samplerTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(tex, samplerTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(tex, samplerTex, uvZ).rgb;

                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }

            half3 TriplanarBumpSample(float3 worldPos, float3 normal, float scale)
            {
                half3 bump = TriplanarSample(_BumpMap, sampler_BumpMap, worldPos, normal, scale);
                bump = normalize((bump * 2 - 1) * _BumpStrength + normal);
                return bump;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half3 normal = normalize(i.normalWS);
                normal = TriplanarBumpSample(i.worldPos, normal, _TextureScale);
                half3 tex = TriplanarSample(_MainTex, sampler_MainTex, i.worldPos, normal, _TextureScale) * _Color.rgb;

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