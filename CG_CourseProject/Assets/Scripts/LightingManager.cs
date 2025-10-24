using UnityEngine;

public class LightingToggle : MonoBehaviour
{
    public Material[] lightingMaterials;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            SetModeForAll(0);
            Debug.Log("Mode 0: No Lighting");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            SetModeForAll(1);
            Debug.Log("Mode 1: Diffuse Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            SetModeForAll(2);
            Debug.Log("Mode 2: Ambient Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            SetModeForAll(3);
            Debug.Log("Mode 3: Specular Only");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            SetModeForAll(4);
            Debug.Log("Mode 4: Diffuse + Ambient");
        }
        else if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            SetModeForAll(5);
            Debug.Log("Mode 5: All Effects");
        }
    }

    void SetModeForAll(int mode)
    {
        foreach (Material mat in lightingMaterials)
        {
            mat.SetInt("_Mode", mode);
        }
    }
}