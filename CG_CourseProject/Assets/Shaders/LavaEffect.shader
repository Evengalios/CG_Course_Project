Shader "URP/LavaEffect"
{
    Properties
    {
        _MainTex ("Lava Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _LavaColor1 ("Lava Color 1", Color) = (1, 0.3, 0, 1)
        _LavaColor2 ("Lava Color 2", Color) = (1, 0.8, 0, 1)
        _FlowSpeed ("Flow Speed", Range(0, 2)) = 0.5
        _DistortionStrength ("Distortion Strength", Range(0, 0.5)) = 0.1
        _EmissionStrength ("Emission Strength", Range(0, 5)) = 2.0
        _NoiseScale ("Noise Scale", Float) = 1.0
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

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            float4 _LavaColor1;
            float4 _LavaColor2;
            float _FlowSpeed;
            float _DistortionStrength;
            float _EmissionStrength;
            float _NoiseScale;
            float _TextureScale;

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                if (_TextureScale < 0.001)
                    return half4(0.2, 0.2, 0.2, 1.0);
                
                float time = _Time.y * _FlowSpeed;
                
                float2 uv1 = i.uv * _NoiseScale + float2(time * 0.1, time * 0.15);
                float2 uv2 = i.uv * _NoiseScale * 1.5 + float2(-time * 0.08, time * 0.12);
                
                half noise1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv1).r;
                half noise2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv2).r;
                
                float2 distortion = float2(noise1, noise2) * _DistortionStrength;
                
                float2 mainUV = i.uv + distortion + float2(0, time * 0.2);
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainUV);
                
                half combinedNoise = (noise1 + noise2) * 0.5;
                half3 lavaColor = lerp(_LavaColor1.rgb, _LavaColor2.rgb, combinedNoise);
                
                half3 finalColor = mainTex.rgb * lavaColor * _EmissionStrength;
                
                half glow = pow(combinedNoise, 2.0) * 0.5;
                finalColor += glow * _LavaColor2.rgb;
                
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }
}