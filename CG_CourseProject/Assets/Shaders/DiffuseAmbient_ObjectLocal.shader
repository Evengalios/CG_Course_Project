Shader "URP/DiffuseAmbient_ObjectLocal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", Range(0,1)) = 0.4
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
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 localPos     : TEXCOORD0;
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
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.localPos = v.positionOS.xyz;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            half3 TriplanarObjectSample(float3 localPos, float3 normal)
            {
                float3 blend = abs(normal);
                blend /= (blend.x + blend.y + blend.z + 1e-5);

                float2 uvX = localPos.yz * _TextureScale;
                float2 uvY = localPos.xz * _TextureScale;
                float2 uvZ = localPos.xy * _TextureScale;

                half3 sampleX = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvX).rgb;
                half3 sampleY = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvY).rgb;
                half3 sampleZ = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvZ).rgb;

                return sampleX * blend.x + sampleY * blend.y + sampleZ * blend.z;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half3 normal = normalize(i.normalWS);
                half3 tex = TriplanarObjectSample(i.localPos, normal) * _Color.rgb;

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
