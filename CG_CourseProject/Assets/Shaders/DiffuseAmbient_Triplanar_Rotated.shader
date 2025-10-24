Shader "URP/DiffuseAmbient_Triplanar_Rotated"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0,1)) = 0.4
        _TextureScale ("Texture World Scale", Float) = 1.0
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
                float3 worldPos     : TEXCOORD0;
                float3 normalWS     : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _Color;
            float _AmbientStrength;
            float _TextureScale;

            Varyings vert(Attributes v)
            {
                Varyings o;
                float3 worldPos = TransformObjectToWorld(v.positionOS.xyz);
                o.positionHCS = TransformWorldToHClip(worldPos);
                o.worldPos = worldPos;
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

            half3 TriplanarSample(float3 worldPos, float3 normal)
            {
                float angleX = radians(10);
                float angleY = radians(10);
                float3 pos = RotateX(worldPos, angleX);
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
                half3 tex = TriplanarSample(i.worldPos, normal) * _Color.rgb;

                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half NdotL = saturate(dot(normal, -lightDir));
                half3 diffuse = mainLight.color * NdotL;

                half3 ambient = SampleSH(normal) * _AmbientStrength;

                half3 lighting = diffuse + ambient;
                return half4(tex * lighting, _Color.a);
            }

            ENDHLSL
        }
    }
}
