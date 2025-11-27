# MidnightEscape: Final Project - Intro to Computer Graphics

**Evangelos Angelou**  
**100876023**  
**Unity Version 2022.3.62f1**

**Final Project Video Presentation**: [YouTube Link]  
**Project Progression README**: [README_ProjectProgression.md](README_ProjectProgression.md)

## Part 1: Improvements

### Improvement 1: Second Level with Hanging Lights
I wanted to expand my game beyond just one level and show that my lighting and shader systems work in different environments. The first level is pretty open with outdoor lighting, so I made a second level that's darker and more confined to contrast the first.

The second level also has more obstacles and hanging lights. I set up a portal at the end of level 1 that triggers the transition to level 2 using collision detection. The hanging lights use the FlickeringLight script I made.

This gives players more content to play through and lets me demonstrate that the shaders can be used in any level. The flickering lights in the second level create a lonely late night city vibe which compliemnts by background.

<img width="1502" height="844" alt="image" src="https://github.com/user-attachments/assets/3f13e936-ed77-4f7c-a3df-0af9465a8da8" />

---

### Improvement 2: Runtime Texture Toggle System
The final project needs textures to be toggleable during gameplay so I can show the difference between textured and untextured objects. I had to manually change materials in the Unity Editor Before which wouldn't work for a live demo.

I made a `TextureToggle.cs` script that saves all the original texture settings when the game starts, then swaps them out when you press T. I used Dictionaries to keep track of each object's original `_TextureScale` and `_Color` values. I had to make sure I modified the material instances instead of the actual material files. I learned that the hard way after accidentally breaking my materials the first time.

```csharp
private Dictionary<Renderer, float> originalScales = new Dictionary<Renderer, float>();
private Dictionary<Renderer, Color> originalColors = new Dictionary<Renderer, Color>();

void StoreOriginalValues()
{
    Renderer[] allRenderers = FindObjectsOfType<Renderer>();
    foreach (Renderer rend in allRenderers)
    {
        if (rend.material.HasProperty("_TextureScale"))
            originalScales[rend] = rend.material.GetFloat("_TextureScale");
        if (rend.material.HasProperty("_Color"))
            originalColors[rend] = rend.material.GetColor("_Color");
    }
}
```

Now when you press T, everything instantly switches between textured and flat-colored mode. It really shows how much textures add to the visual quality as the scene looks way more boring and unpolished without them.

<img width="1505" height="847" alt="image" src="https://github.com/user-attachments/assets/3baaf438-6483-45ea-b635-f8fa3de9ad0b" />


---


### Improvement 3: Better Texture Toggle Support Across All Shaders
My new visual effect shaders (lava, protal energy pulse, cell shading) needed to work with the texture toggle system. Each shader needed the `_TextureScale` property check so they wouldn't break when I press T.

I Added a simple check at the start of each fragment shader that returns a gray color if `_TextureScale` is below a certain threshold. This way all my shaders respond to the same toggle system.

```hlsl
if (_TextureScale < 0.001)
    return half4(0.2, 0.2, 0.2, 1.0);
```

Now everything toggles consistently. Whether it's the lava effect or the cell-shaded objects, pressing T works on everything. Makes the demo much cleaner.

**[ADD SCREENSHOT: Various effects with textures toggled off showing gray fallback]**

---

## Part 2: Texturing

For this prokect, I'm using triplanar mapping for pretty much everything instead of regular UV mapping. The main reason is that triplanar mapping  works better for objects that move or rotate as the textures stay locked to the objects instead of sliding around.

### Triplanar Mapping Implementation

The way triplanar mapping works is it projects the texture from three directions (X, Y, and Z axes) and blends them based on which way the surface is facing.

```hlsl
float3 blend = abs(normalOS);
blend = pow(blend, _BlendSharpness);
blend /= (blend.x + blend.y + blend.z + 1e-5);

float2 uvX = posOS.zy * scale;
float2 uvY = posOS.xz * scale;
float2 uvZ = posOS.xy * scale;
```

The cool thing is that this completely avoids the stretching I get with UV mapping on cubes and other blocky shapes. Each face gets a clean projection and my blend factor controls how sharp the transitions are between each face of the object.

### Textures I'm Using

**Brick Textures**: I'm using them on most of the platforms because they give the feel of a city walkway. The gray colour fits the midnight theme too.

**Lava Textures**: For the lava I'm using a basic texture but the shader does most of the work. The flowing animation and color shifting makes it look way more interesting than a static texture would.

**Fabric Texture**: Using this on the player ball. I picked fabric because the ball needs to look different from the environment but still fit the low-poly aesthetic.

**Wood Texture**: Using it on the two platforms over ther lava. I picked wood because the textyure and brown colour contrasts the rest of the scene and makes the lava jumps look rickety and dangeous.

<img width="694" height="486" alt="image" src="https://github.com/user-attachments/assets/a7aea543-281f-4e06-8760-e185047a2e5a" /> <img width="259" height="247" alt="image" src="https://github.com/user-attachments/assets/96c31d71-b0af-4564-b3c0-1b1d4029de83" />

<img width="723" height="450" alt="image" src="https://github.com/user-attachments/assets/464ff4bb-38a7-48ab-bd92-42c2ba130df5" />


### Why I Chose These Colours

I went with warm colours (oranges, reds, browns) for some parts of the scene while using cooler colours (gray, purple, blue) for others as I wanted a twilight/midnight vibe but with dangerous areas. The lava is super saturated red-orange to make it obvious that it's dangerous. The cooler blues, purples and cyans show up in the coins, background and portal effects to create visual contrast with all the warm tones and to feel safer.

### Normal Mapping

I also added normal mapping support to pretty much all of the shaders as well. Normal maps add depth to flat surfaces without needing more polygons and sacrificing performance. For the brick textures, the normal map shows all the grooves and bumps between bricks which makes them look more real.

```hlsl
half3 TriplanarNormal(float3 posOS, float3 normalOS, float3 normalWS, float scale)
{
    float3 blend = abs(normalOS);
    blend = pow(blend, 4);
    blend /= (blend.x + blend.y + blend.z + 1e-5);
    
    half3 normalX = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvX));
    half3 normalY = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvY));
    half3 normalZ = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvZ));
    
    half3 blendedNormal = normalX * blend.x + normalY * blend.y + normalZ * blend.z;
    return normalize(normalWS + blendedNormal * _NormalStrength);
}
```

### Runtime Toggling

All my shaders check the `_TextureScale` property. When the TextureToggle script sets it to basically zero, the shader just returns a flat gray color instead of sampling the texture. 

```hlsl
if (_TextureScale < 0.001)
    return half4(0.2, 0.2, 0.2, 1.0);
```

## Part 3: Visual Effects

### Effect 1: Animated Lava Shader

**How It Works**: The lava effect uses two layers of scrolling noise to create a flowing molten look. I sample a noise texture at two different speeds and directions, use the values to distort the main texture coords, then blend between two lava colors based on the noise. Finally I add some extra glow by squaring the noise value.

```hlsl
float2 uv1 = i.uv * _NoiseScale + float2(time * 0.1, time * 0.15);
float2 uv2 = i.uv * _NoiseScale * 1.5 + float2(-time * 0.08, time * 0.12);

half noise1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv1).r;
half noise2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv2).r;

float2 distortion = float2(noise1, noise2) * _DistortionStrength;
float2 mainUV = i.uv + distortion + float2(0, time * 0.2);

half combinedNoise = (noise1 + noise2) * 0.5;
half3 lavaColor = lerp(_LavaColor1.rgb, _LavaColor2.rgb, combinedNoise);

half3 finalColor = mainTex.rgb * lavaColor * _EmissionStrength;
half glow = pow(combinedNoise, 2.0) * 0.5;
finalColor += glow * _LavaColor2.rgb;
```

I needed an obvious hazard that players would recognize immediately. The flowing animation catches your eye and screams "don't touch." I'm very happy with how it turned out and this is by far my favourite effect.

---

### Effect 2: Energy Wave Pulse Shader

**How It Works**: This one combines a few different effects. First there's Rim lighting that makes the edges glow brighter than the center. Then I added a pulsing animation using a sine wave over time, and then a vertical wave pattern that scrolls. Everything gets multiplied together and you end up with a pulsing energy effect.

```hlsl
float rim = pow(1.0 - saturate(dot(normalWS, viewDirWS)), _Rim);
float pulse = sin(_Time.y * _PulseSpeed) * 0.5 + 0.5;
float wave = sin((IN.uv.y * _WaveFrequency + _Time.y * _WaveSpeed) * 6.28318);
wave = wave * 0.5 + 0.5;

float3 color = lerp(_SecondaryColor.rgb, _MainColor.rgb, wave);
color *= rim * (pulse * 0.5 + 0.5);
float3 emission = color * _EmissionStrength;
```

I something that would draw attention to the portal. I felt like it was hard to identify that the portal was the goal originally, but this energy wave effect is the first thing that catches your eye, making sure that players CANT miss it.

---

### Effect 3: Cell Shading with Outlines

**How It Works**: My Cell shading Shader uses two rendering passes. The first pass renders the back faces of the object pushed out along the normals which  creates an outline. The second pass renders the front faces normally but with lighting bands instead of smooth lighting. I quantize the lighting by flooring the dot product value which creates the bands of light.

```hlsl
// First Pass: Outline
float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
positionWS += normal * _OutlineWidth;

// Second Pass: Cell Shading
float NdotL = dot(normal, -lightDir);
NdotL = (NdotL + 1.0) * 0.5;

float bandStep = 1.0 / _Bands;
float bandedLight = floor(NdotL / bandStep) * bandStep;

half3 litColor = lerp(_ShadowColor.rgb, _Color.rgb, bandedLight);
```

I thought it would be cool to have some stylized platforms and hanging lights mixed in with the more realistic stuff. The cartoon look makes the platforms pop out visually and tell the player "Jump Here". I think the cell shaded look also compliments the realistic lava effect very well.

---

## Controls & Toggles

### Lighting Modes
Press the number keys to switch between different lighting setups:

- **0** - Albedo Only (no lighting at all, just raw textures)
- **1** - Diffuse Only (Lambert diffuse lighting)
- **2** - Ambient Only (just ambient light from the environment)
- **3** - Specular Only (Phong specular highlights with darkened base)
- **4** - Diffuse + Ambient (both combined)
- **5** - Full Lighting (all lighting effects together)

### Effect Toggles
- **T** - Toggle all textures on/off
- **L** - Toggle colour grading (LUT) on/off
### Movement
- **WASD** - Move the ball around
- **Space** - Jump

---

## Attributions

### Code & Learning Resources
- Triplanar mapping technique from Catlike Coding: https://catlikecoding.com/unity/tutorials/advanced-rendering/triplanar-mapping/
- Base shader templates from course materials
- Unity docs and Stack Overflow for fixing shader compilation errors

### Music
- Gymnopédie No. 1 by Kevin MacLeod (Erik Satie) - Creative Commons Attribution 3.0 - http://creativecommons.org/licenses/by/3.0/

### Assets
- Background image made with DALL-E 2
- 25 Free Stylized Textures (Unity Asset Store) - crystal textures
- Rain Maker (Unity Asset Store) - particle system
- Tileable Bricks Wall (Unity Asset Store) - brick textures for platforms
- Yughues Free Fabric Materials (Unity Asset Store) - player ball material
- Yughues Free Wooden Floor Materials (Unity Asset Store) - cell shading wood texture
- Stylized Lava Texture (Unity Asset Store) - moving lava texture
### Tools
- Unity 2022.3.62f1
- Visual Studio for coding
- Photopea for making the LUTs
