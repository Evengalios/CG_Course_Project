using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class LUTController : MonoBehaviour
{
    public Volume volume;

    private ColorLookup colorLookup;
    private bool lutEnabled = false;

    void Start()
    {
        if (volume != null && volume.profile.TryGet(out colorLookup))
        {
            lutEnabled = false;
            colorLookup.active = false;
            Debug.Log("LUT started: OFF");
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.L))
        {
            lutEnabled = !lutEnabled;

            if (colorLookup != null)
            {
                colorLookup.active = lutEnabled;
                Debug.Log("LUT: " + (lutEnabled ? "ON" : "OFF"));
            }
        }
    }
}