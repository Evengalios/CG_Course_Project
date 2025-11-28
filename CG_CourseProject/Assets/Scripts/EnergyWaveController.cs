using UnityEngine;

public class EnergyWaveController : MonoBehaviour
{
    [Header("Wave Settings")]
    public Color mainColor = new Color(0f, 1f, 1f, 0.8f);
    public Color secondaryColor = new Color(0f, 0.5f, 1f, 0.8f);
    public float pulseSpeed = 2f;
    public float waveSpeed = 1f;
    public float waveFrequency = 3f;
    public float emissionStrength = 2f;
    public float rimPower = 2f;

    [Header("Spawning Waves")]
    public bool spawnWaveRings = true;
    public GameObject waveRingPrefab;
    public float waveSpawnInterval = 1f;
    public float waveExpandSpeed = 2f;
    public float waveLifetime = 3f;

    private Material material;
    private float nextWaveTime;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        UpdateMaterial();
    }

    void Update()
    {
        UpdateMaterial();

        if (spawnWaveRings && waveRingPrefab != null && Time.time >= nextWaveTime)
        {
            SpawnWaveRing();
            nextWaveTime = Time.time + waveSpawnInterval;
        }
    }

    void UpdateMaterial()
    {
        if (material != null)
        {
            material.SetColor("_MainColor", mainColor);
            material.SetColor("_SecondaryColor", secondaryColor);
            material.SetFloat("_PulseSpeed", pulseSpeed);
            material.SetFloat("_WaveSpeed", waveSpeed);
            material.SetFloat("_WaveFrequency", waveFrequency);
            material.SetFloat("_EmissionStrength", emissionStrength);
            material.SetFloat("_Rim", rimPower);
        }
    }

    void SpawnWaveRing()
    {
        GameObject ring = Instantiate(waveRingPrefab, transform.position, Quaternion.identity);
        WaveRing waveRingScript = ring.GetComponent<WaveRing>();
        if (waveRingScript != null)
        {
            waveRingScript.expandSpeed = waveExpandSpeed;
            waveRingScript.lifetime = waveLifetime;
        }
        else
        {
            ring.AddComponent<WaveRing>().expandSpeed = waveExpandSpeed;
            ring.GetComponent<WaveRing>().lifetime = waveLifetime;
        }
    }
}