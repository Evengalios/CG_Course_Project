# MidnightEscape: Intro to Computer Graphics Project Progression - README

---

## 1. Project Overview

This repository contains the Unity project for the **Intro to Computer Graphics Project Progression** submission. The core of this assignment was to build a foundational, custom-shaded environment (`MidnightEscape`) by implementing essential computer graphics concepts entirely through **custom HLSL shaders** in the Universal Render Pipeline (URP).

| Deliverable | Status |
| :--- | :--- |
| **Part 1: Base Scene** | Complete |
| **Part 2: Illumination (5 Modes)** | Complete (Implemented in `URP/Part2_UnifiedLighting` shader) |
| **Part 3: Color Grading** | Complete (Custom Warm LUT) |
| **Part 4: Shaders and Effects (2 Required)** | Complete (Normal Mapping & Rim Lighting) |

[!!! INSERT SCREENSHOT 1: Final look of the full scene (`MidnightEscape`) with all shaders (Normal Map, Rim, and Color Grading) applied. !!!]

---

## 2. Student Information & Build Links

* **Student Full Name:** Evangelos Angelou
* **Student ID:** 100876023
* **Project Type:** Individual Submission
* **Unity Project Version:** [Specify Unity Version, e.g., Unity 2021.3 LTS]

| Resource | Link |
| :--- | :--- |
| **Playable Build Link** | [Insert Link to Playable Build on GitHub Release] |
| **Video Presentation Link** | [Insert Link to Unlisted YouTube Video] |

---

## 3. Part 1: Base Scene Implementation

### Scene Design and Atmosphere
The scene is a low-poly obstacle course featuring platforms and walls textured with realistic-ish stone and brick textures. The atmosphere is designed to be subdued and contemplative, using a subtle rain overlay and the ambient music of *Gymnopédie No. 1*.

### Dynamic Objects & Core Objective
The scene includes moving objects to ensure implemented effects are tested dynamically:
* **Dynamic Game Objects:** Includes a rotating central platform, patrolling cuboid enemies, and floating collectible gems. The movement confirms that real-time effects like Specular highlights remain stable.
* **Playable Character:** The player controls a **Shiny Red Ball**, whose simple, curved nature is ideal for clearly showcasing the required **Specular Highlights** and **Rim Lighting**.
* **Win Condition:** The player completes the level by navigating the course and entering the final **Portal**.

---

## 4. Part 2: Illumination Implementation (5 Modes)

My solution was to unify all standard lighting models into a single, custom shader: `URP/Part2_UnifiedLighting`. This shader uses an integer property (`_Mode`) to switch instantly between the five required states, fulfilling the isolation and demonstration requirement.

### Illumination Mode Composition

| Mode Key | Illumination State | Logic Demonstrated |
| :--- | :--- | :--- |
| `0` | Albedo Only | Texture color only, bypassing all lighting calculations. |
| `1` | Diffuse Lighting Only | Standard Lambertian lighting (`N * L`). |
| `2` | Ambient Lighting Only | Pure Spherical Harmonic (SH) ambient light. |
| `3` | Specular Lighting Only | Phong Specular highlights layered on top of a base color. |
| `4` | Diffuse + Ambient | Combination of Diffuse and Ambient lighting components. |
| `5 (Full)` | Diffuse + Ambient + Specular | The complete, combined lighting stack for the final look. |

[!!! INSERT SCREENSHOT 2: Side-by-side or GIF showing the switch between **Mode 1 (Diffuse)** and **Mode 5 (Full Illumination)** on an object. !!!]

### Critical Implementation Detail: World-Space Triplanar Mapping
To ensure consistent texturing across the geometry without visible seams or stretching (as the low-poly models are not UV-unwrapped), I sample all textures based on **world-space position**. This technique blends three axial projections using the object's world-space normal.

---

## 5. Part 4: Shaders and Effects

The two required custom shader effects are combined into the advanced shader: `URP/Part3_Triplanar_NormalMap_RimLighting_Unified`.

### 1. Normal Mapping (Required)
* **Description:** Adds the illusion of complex surface depth (e.g., crevices in the brick texture) without increasing the polygon count.
* **Implementation:** The Normal Map texture is sampled via a **Triplanar function**. I then construct the **TBN (Tangent, Bitangent, Normal) matrix** to transform the sampled normal into a **perturbed World-Space normal**. This perturbed normal is used for all subsequent lighting calculations.
* **Formula Focus:** The core logic involves World-Space normal transformation within the vertex/fragment pipeline.

### 2. Rim Lighting (Required)
* **Description:** A stylized, glowing outline that highlights the silhouette of objects against the backdrop.
* **Implementation:** The rim value is calculated using the falloff formula: `Rim = 1.0 - saturate(dot(Normal, ViewDir))`. This value is then controlled by the `_RimPower` and `_RimIntensity` properties and **additively blended** into the final lit color.
* **Benefit:** Improves player visibility and reinforces the stylized atmosphere.

[!!! INSERT SCREENSHOT 3: Close-up of a wall showing the dramatic difference between the material **with** Normal Mapping and **without** (or simply an intense close-up of a well-lit brick surface). !!!]

---

## 6. Part 3: Color Grading

### Custom Warm Color Lookup Table (LUT)
* **Implementation:** I authored a custom 3D LUT texture. The grading process was designed to **increase red and yellow hues** and overall saturation. The resulting look features **purplish-red shadow tones** that shift into **bright, golden-orange highlights**.
* **Benefit:** This post-processing step unifies the scene's palette, giving `MidnightEscape` a consistent, high-contrast, and cinematic visual feel.

[!!! INSERT SCREENSHOT 4: Side-by-side image of the scene **Before** and **After** applying the Warm Color LUT to show the atmospheric change. !!!]

*I believe this structure and level of detail fully satisfy the requirements of the Project Progression assignment.*
