using UnityEngine;

public class LightingToggle : MonoBehaviour
{
    private int currentMode = 5;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            currentMode = 0;
            SetModeForAll(0);
            Debug.Log("Mode 0: No Lighting");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            currentMode = 1;
            SetModeForAll(1);
            Debug.Log("Mode 1: Diffuse Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            currentMode = 2;
            SetModeForAll(2);
            Debug.Log("Mode 2: Ambient Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            currentMode = 3;
            SetModeForAll(3);
            Debug.Log("Mode 3: Specular Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            currentMode = 4;
            SetModeForAll(4);
            Debug.Log("Mode 4: Diffuse + Ambient");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            currentMode = 5;
            SetModeForAll(5);
            Debug.Log("Mode 5: All Effects");
        }
    }

    void SetModeForAll(int mode)
    {
        Renderer[] allRenderers = FindObjectsOfType<Renderer>();

        foreach (Renderer rend in allRenderers)
        {
            if (rend != null && rend.material.HasProperty("_Mode"))
            {
                rend.material.SetInt("_Mode", mode);
            }
        }
    }
   
}