using UnityEngine;

public class DanglingLight : MonoBehaviour
{
    [Header("Swing Settings")]
    [Tooltip("How fast the light swings back and forth")]
    public float swingSpeed = 1f;
    
    [Tooltip("Maximum swing angle in degrees")]
    public float swingAngle = 15f;
    
    [Tooltip("Swing on X axis (left-right) or Z axis (forward-back)")]
    public bool swingOnXAxis = false;
    
    [Header("Light Flicker Settings")]
    [Tooltip("Enable random flickering effect")]
    public bool enableFlicker = false;
    
    [Tooltip("Minimum light intensity when flickering")]
    public float minIntensity = 3f;
    
    [Tooltip("Maximum light intensity when flickering")]
    public float maxIntensity = 8f;
    
    [Tooltip("How often flicker happens (0-1, higher = more frequent)")]
    public float flickerFrequency = 0.05f;
    
    [Header("Bulb Visual Flicker")]
    [Tooltip("Enable the bulb mesh material to flicker too")]
    public bool enableBulbFlicker = true;
    
    [Tooltip("Minimum emission intensity for bulb material")]
    public float minBulbEmission = 0f;
    
    [Tooltip("Maximum emission intensity for bulb material")]
    public float maxBulbEmission = 1f;
    
    private Light lightComponent;
    private Renderer bulbRenderer;
    private Material bulbMaterial;
    private Color baseEmissionColor = Color.white;
    private float randomOffset;
    private float swingDirection;
    
    void Start()
    {
        lightComponent = GetComponentInChildren<Light>();
        
        Transform bulbTransform = transform.Find("LightBulb");
        if (bulbTransform != null)
        {
            bulbRenderer = bulbTransform.GetComponent<Renderer>();
            if (bulbRenderer != null)
            {
                Color originalEmission = Color.black;
                if (bulbRenderer.sharedMaterial.HasProperty("_EmissionColor"))
                {
                    originalEmission = bulbRenderer.sharedMaterial.GetColor("_EmissionColor");
                }
                
                bulbMaterial = new Material(bulbRenderer.sharedMaterial);
                bulbRenderer.material = bulbMaterial;
                
                bulbMaterial.EnableKeyword("_EMISSION");
                
                if (originalEmission.maxColorComponent > 0.1f)
                {
                    float maxComponent = Mathf.Max(originalEmission.r, originalEmission.g, originalEmission.b);
                    baseEmissionColor = new Color(
                        originalEmission.r / maxComponent,
                        originalEmission.g / maxComponent,
                        originalEmission.b / maxComponent,
                        1f
                    );
                }
                else
                {
                    baseEmissionColor = new Color(1f, 0.8f, 0.4f, 1f);
                }
                
                Debug.Log("Base Emission Color (normalized): " + baseEmissionColor);
                Debug.Log("Original Emission (HDR): " + originalEmission);
                
                Color initialEmission = baseEmissionColor * minBulbEmission;
                bulbMaterial.SetColor("_EmissionColor", initialEmission);
                DynamicGI.SetEmissive(bulbRenderer, initialEmission);
            }
        }
        
        randomOffset = Random.Range(0f, 100f);
        swingDirection = Random.value > 0.5f ? 1f : -1f;
    }
    
    void Update()
    {
        float time = Time.time + randomOffset;
        float angle = Mathf.Sin(time * swingSpeed) * swingAngle * swingDirection;
        
        if (swingOnXAxis)
        {
            transform.localRotation = Quaternion.Euler(angle, 0, 0);
        }
        else
        {
            transform.localRotation = Quaternion.Euler(0, 0, angle);
        }
        
        if (enableFlicker && lightComponent != null)
        {
            if (Random.value < flickerFrequency)
            {
                float newIntensity = Random.Range(minIntensity, maxIntensity);
                lightComponent.intensity = newIntensity;

                if (enableBulbFlicker && bulbMaterial != null)
                {
                    float normalizedIntensity = (newIntensity - minIntensity) / (maxIntensity - minIntensity);
                    float emissionIntensity = Mathf.Lerp(minBulbEmission, maxBulbEmission, normalizedIntensity);
                    
                    Color emissionColor = baseEmissionColor * emissionIntensity;
                    bulbMaterial.SetColor("_EmissionColor", emissionColor);
                    
                    DynamicGI.SetEmissive(bulbRenderer, emissionColor);
                }
            }
        }
        else if (enableBulbFlicker && !enableFlicker && bulbMaterial != null)
        {
            if (Random.value < flickerFrequency)
            {
                float emissionIntensity = Random.Range(minBulbEmission, maxBulbEmission);
                Color emissionColor = baseEmissionColor * emissionIntensity;
                bulbMaterial.SetColor("_EmissionColor", emissionColor);
                DynamicGI.SetEmissive(bulbRenderer, emissionColor);
            }
        }
    }
    
    void OnDestroy()
    {
        if (bulbMaterial != null)
        {
            Destroy(bulbMaterial);
        }
    }
    
    void OnDrawGizmos()
    {
        Light light = GetComponentInChildren<Light>();
        if (light != null)
        {
            Gizmos.color = new Color(1f, 1f, 0f, 0.3f);
            if (light.type == LightType.Point)
            {
                Gizmos.DrawWireSphere(light.transform.position, light.range);
            }
            else if (light.type == LightType.Spot)
            {
                Gizmos.color = Color.yellow;
                Gizmos.DrawRay(light.transform.position, light.transform.forward * light.range);
            }
        }
    }
}