using UnityEngine;
using System.Collections.Generic;

public class TextureToggle : MonoBehaviour
{
    public KeyCode toggleKey = KeyCode.T;

    private bool texturesEnabled = true;
    private Dictionary<Renderer, float> originalScales = new Dictionary<Renderer, float>();
    private Dictionary<Renderer, Color> originalColors = new Dictionary<Renderer, Color>();
    private bool initialized = false;

    void Start()
    {
        StoreOriginalValues();
    }

    void StoreOriginalValues()
    {
        Renderer[] allRenderers = FindObjectsOfType<Renderer>();

        foreach (Renderer rend in allRenderers)
        {
            if (rend == null) continue;

            if (rend.material.HasProperty("_TextureScale"))
                originalScales[rend] = rend.material.GetFloat("_TextureScale");

            if (rend.material.HasProperty("_Color"))
                originalColors[rend] = rend.material.GetColor("_Color");
        }

        initialized = true;
    }

    void Update()
    {
        if (Input.GetKeyDown(toggleKey))
        {
            if (!initialized)
                StoreOriginalValues();

            texturesEnabled = !texturesEnabled;

            Renderer[] allRenderers = FindObjectsOfType<Renderer>();

            foreach (Renderer rend in allRenderers)
            {
                if (rend == null) continue;

                if (texturesEnabled)
                {
                    if (originalScales.ContainsKey(rend))
                        rend.material.SetFloat("_TextureScale", originalScales[rend]);

                    if (originalColors.ContainsKey(rend))
                        rend.material.SetColor("_Color", originalColors[rend]);
                }
                else
                {
                    rend.material.SetFloat("_TextureScale", 0.0001f);
                    rend.material.SetColor("_Color", Color.gray);
                }
            }

            Debug.Log("Textures: " + (texturesEnabled ? "ON" : "OFF"));
        }
    }

}