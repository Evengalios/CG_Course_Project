Shader "URP/Part2Lighting_Rotated"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0,1)) = 0.4
        _SpecularStrength ("Specular Strength", Range(0,1)) = 0.5
        _Shininess ("Shininess", Range(1,128)) = 32
        _TextureScale ("Texture Scale", Float) = 1.0
        _LightingMode ("Lighting Mode (0=None,1=Ambient,2=Diffuse,3=Diffuse+Ambient,4=Custom)", Range(0,4)) = 3
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
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos    : TEXCOORD0;
                float3 localPos    : TEXCOORD1;
                float3 normalWS    : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _Color;
            float _AmbientStrength;
            float _SpecularStrength;
            float _Shininess;
            float _TextureScale;
            float _LightingMode;

            Varyings vert(Attributes v)
            {
                Varyings o;
                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.positionHCS = TransformWorldToHClip(worldPos);
                o.worldPos = worldPos;
                o.localPos = v.positionOS.xyz;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            // Rotation helpers
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

            // Object-local triplanar mapping with rotation
            half3 TriplanarObjectSample(float3 localPos, float3 normal)
            {
                // Apply -10° rotation
                float angleX = radians(-10);
                float angleY = radians(-10);
                float3 pos = RotateX(localPos, angleX);
                pos = RotateY(pos, angleY);

                float3 blend = abs(normal);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = pos.yz * _TextureScale;
                float2 uvY = pos.xz * _TextureScale;
                float2 uvZ = pos.xy * _TextureScale;

                half3 sampleX = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvZ).rgb;

                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half3 normal = normalize(i.normalWS);
                half3 tex;

                // Decide base texture
                if (_LightingMode == 4)
                {
                    tex = TriplanarObjectSample(i.localPos, normal) * _Color.rgb; // custom rotated triplanar
                }
                else
                {
                    tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.localPos.xy * _TextureScale).rgb * _Color.rgb;
                }

                // Lighting
                half3 diffuse = half3(0,0,0);
                half3 ambient = half3(0,0,0);
                half3 specular = half3(0,0,0);

                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half NdotL = saturate(dot(normal, -lightDir));

                if (_LightingMode == 2 || _LightingMode == 3 || _LightingMode == 4)
                    diffuse = mainLight.color * NdotL;

                if (_LightingMode == 1 || _LightingMode == 3 || _LightingMode == 4)
                    ambient = SampleSH(normal) * _AmbientStrength;

                if (_LightingMode == 4)
                {
                    half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                    half3 halfDir = normalize(lightDir + viewDir);
                    half spec = pow(saturate(dot(normal, halfDir)), _Shininess);
                    specular = spec * mainLight.color * _SpecularStrength;
                }

                half3 lighting = diffuse + ambient + specular;

                return half4(tex * lighting, _Color.a);
            }

            ENDHLSL
        }
    }
}
