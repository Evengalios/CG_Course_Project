# MidnightEscape: Intro to Computer Graphics Project Progression - README

---

## Overview

This repository cointains all my work for the Project Progression.



<img width="1503" height="844" alt="image" src="https://github.com/user-attachments/assets/7b87154c-5fe5-46d3-8eb4-8499691fb3ee" />



**Evangelos Angelou**  
**100876023**  
**Unity Version 2022.3.62f1**  


**Video Presentation Link** - [Video Report](https://www.youtube.com/watch?v=B7QhVo-8cMk) 

---

## Base Scene

### Atmosphere
I designed **MidnightEscape** to be a low-poly 2.5D obstacle course. I textured the platforms and walls with realistic-ish stone and brick materials. The overall mood is somber and relaxing, which I achieved by adding a subtle 3D rain overlay and *Gymnopédie No. 1* for the ambient background music. In order to get the 2.5D effect I used 3D objects in the 2D engine and rotated/adjusted every object in 3D space to give the illusion of 2.5D

### Dynamic Objects & Core Objective

**Dynamic Game Objects:** I included a rotating central platform, simple cube enemies that patrol an area, and floating collectible gems. These moving elements confirm that my Specular highlights and Normal Mapping calculations remain stable regardless of the object's position or rotation.  

**Playable Character:** I chose a Shiny Red Ball as the player character. Its simple, curved geometry is ideal for clearly showcasing surface effects like Specular Highlights.  
  
**Win Condition:** The level is completed by navigating the course and entering the final Portal.

### **Asset Implementations**

**Stylized Crystal Texture for Collectibles (Coins)** -
I chose the blue crystal texture from the 25 Free Stylized Textures pack to replace a bland default coin asset, as I felt the crystals would look cool with custom lighting. I combined this texture with a custom shader to achieve Normal Mapping and Rim Lighting (required for Part 3). I used the crystal's Normal Map input to simulate depth, making the crystal texture pop. Lastly, I added the Rim Lighting effect to the shader's final output, making the colour and intensity adjustable properties in the inspector. This visual combination makes the collectible objects visually pop out.

**Rain Maker Prefab for Environment** -
The Rain Maker particle system prefab was added to create a realistic environment, and play into the game's calm and mellow theme. I started with the base 3D rain particle system. However, due to compatibility problems with the render pipeline, I modified the prefab to use the 2D Sprite materials for the particle texture instead. I had to swap the particle renderer settings and adjusting the particle z-axis size to keep the illusion of 2D volume.

**Tileable Brick Wall Textures for Platforms** -
I used the Brick Wall texture on the floor and platforms to make them look solid and three-dimensional. The normal map was important because it's what makes a flat texture look like it has real bumps and grooves, which is necessary for the platforms to feel tactile under my lighting. My main goal with this was to make sure the bricks didn't look huge or tiny, Which is what motived me to incorporate _Triplanar Mapping_. (Talked About Further Down)  

**Yughues' Free Fabric Materials for Playable Character's Ball** -
I used a fabric material texture from the Yughues Free Fabric Materials pack for the main playable character (a ball). I believed keeping the as character a ball that rolls would not only be entertaining, but would 
allow me to show all the lighting effects (especially specular) easily. 

---

## Part 2: Illumination Implementation (5 Modes)

My solution to demonstrate the five lighting components was to unify them into a single, custom shader: `URP/Part2_UnifiedLighting`. This shader uses an int (`_Mode`) that I can switch to isolate every component.

### Illumination Modes

| Mode Key | Lighting | What is Added |
| :--- | :--- | :--- |
| `0` | Albedo Only | Just the texture color, bypassing all lighting calculations. |
| `1` | Diffuse Lighting Only | Basic Lambert lighting (`N * L`). |
| `2` | Ambient Lighting Only | Ambient light, which I can scale. |
| `3` | Specular Lighting Only | Phong Specular highlights layered over the base color. |
| `4` | Diffuse + Ambient | Combining Diffuse and Ambient components. |
| `5` | Diffuse + Ambient + Specular | The complete and combined lighting that I used for the final look of the scene. |
  
**Mode 0**
<img width="1349" height="759" alt="image" src="https://github.com/user-attachments/assets/03fce022-4ce8-4041-8190-de119a14fcb5" />

**Mode 5**
<img width="1503" height="844" alt="image" src="https://github.com/user-attachments/assets/7b87154c-5fe5-46d3-8eb4-8499691fb3ee" />


**Why Triplanar Mapping was Necessary (_My Contribution_)**
My original shader, URP/DiffuseAmbient_ObjectLocal, used simple texture coordinates that look distorted on complex objects. For moving objects like the coins and the rotating platform, this was a big issue. If the texture coordinates were based on the world, the object would appear slide through the texture as it moved.
<img width="843" height="1601" alt="image" src="https://github.com/user-attachments/assets/401607fc-070b-446c-970c-ffa3f30dca5c" /> 



To fix this, I completely rebuilt the texturing process in the new shaders (Part2 and Part3) using Object Space Triplanar Mapping, which fixed my problem:

<img width="774" height="482" alt="image" src="https://github.com/user-attachments/assets/baf82a4c-ad8e-4f8a-a68b-8c3fa0e7ad39" />



By having the texture coordinates based on an object's local position, the texture is stuck to the object. It moves, rotates, and warps perfectly with the object, getting rid of the sliding effect that occurs with moving world-space textures. It also ensures I have a consistent size for the texture across all models, regardless of how large they are or whether their original UVs are laid out badly. Adding this made the shader much more usable in the project and was added to my combined shaders `URP/Part3_Triplanar_NormalMap_RimLighting_Unified` and `URP/Part2_UnifiedLighting`. In order to learn how to use Triplanar Mapping in HLSL I used the _Catlike Coding_ Tutorial: https://catlikecoding.com/unity/tutorials/advanced-rendering/triplanar-mapping/ 

---

## Part 3: Color Grading / Shaders and Effects

I combined the two  custom shader effects into one shader: `URP/Part3_Triplanar_NormalMap_RimLighting_Unified`.

### **Normal Mapping**  
This adds the appearence of depth (e.g., grooves in the brick) without using more geometry.  
**Implementation:** I sampled the Normal Map texture using a Triplanar function. <img width="762" height="177" alt="image" src="https://github.com/user-attachments/assets/f8e25db9-6e7e-48a0-a1ce-28f2e983b324" />  
Then in the fragment shader I used the TBN matrix to turn the sampled tangent-space normal into a World-Space normal. <img width="745" height="194" alt="image" src="https://github.com/user-attachments/assets/f78b169d-7a58-4353-90ae-d1a4f22333f7" />  


### **Rim Lighting**  
This is a soft, glowing outline that makes an object's silhouette pop out against the background.  
**Implementation:** I calculated the rim value using the formula shown in class and in the Alvaro shader: `Rim = 1.0 - saturate(dot(Normal, ViewDir))`. I can control the tightness and intensity of the glow using the `_RimPower` and `_RimIntensity` properties before additively blending it into the final lit color.  
  
Low Rim Power
<img width="43" height="54" alt="image" src="https://github.com/user-attachments/assets/3512d8dc-b0ca-4129-91dd-d6cc91cd7140" /> 

High Rim Power  
<img width="40" height="59" alt="image" src="https://github.com/user-attachments/assets/a5a83013-6685-42d6-b956-a499d768765c" />  

### **LUT Colour Grading**  
For the Colour Grading I decided to use a Warm LUT to make the scene feel more stressful and serious/intense. The warmer filter pushed colours towards more red and purple rather than blue. The
yellows were also way more vibrant and almost yellow, which made the horizon line in the background pop. I used _Photopea_ to create the Warm LUT and used the LUT Colour Grading shader posted on canvas to 
add the post processing colour grading.

**My Warm LUT**  
<img width="256" height="16" alt="WarmLUT" src="https://github.com/user-attachments/assets/8f2b653d-10e4-40d1-a084-89ad259081fd" />  

**Scene With LUT Added**  
<img width="1399" height="786" alt="image" src="https://github.com/user-attachments/assets/61d52498-b6c7-48d7-8262-136466ec80c1" />

---

# Attributions and Licensing

My project relies on external assets, music, and imagery, which are acknowledged below. All materials are used according to respective licenses.

## Code  

**Triplanar Mapping** - https://catlikecoding.com/unity/tutorials/advanced-rendering/triplanar-mapping/  
**Starter Shaders** - In Course Provided Shaders  
**HLSL Help and Compiling Issues** - youtube.com, https://docs.unity.com/en-us, stackoverflow.com  



## Music

**Gymnopédie No. 1** - Kevin MacLeod (Erik Satie) - CC BY 3.0 - *Gymnopédie No. 1* Kevin MacLeod (incompetech.com) Licensed under Creative Commons: By Attribution 3.0 License.  
[http://creativecommons.org/licenses/by/3.0/](http://creativecommons.org/licenses/by/3.0/) 

## Visual Assets & Background

**Background Photo** - Generative AI - Image generated using DALL-E 2 AI. 

## Unity Asset Store Packages

The following free assets were utilized in the project:

| Asset Name | Category | Asset Store Link |
| :--- | :--- | :--- |
| **25 Free Stylized Textures** | Textures/Materials | [Link](https://assetstore.unity.com/packages/2d/textures-materials/25-free-stylized-textures-grass-ground-floors-walls-more-241895) |  
| **Rain Maker** | VFX/Particles | [Link](https://assetstore.unity.com/packages/vfx/particles/environment/rain-maker-2d-and-3d-rain-particle-system-for-unity-34938) |
| **Tileable Bricks Wall** | Textures/Materials | [Link](https://assetstore.unity.com/packages/2d/textures-materials/brick/tileable-bricks-wall-24530) |
| **Yughues Free Fabric Materials** | Textures/Materials | [Link](https://assetstore.unity.com/packages/2d/textures-materials/fabric/yughues-free-fabric-materials-13002)
