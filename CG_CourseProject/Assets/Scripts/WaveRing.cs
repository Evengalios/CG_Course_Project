using UnityEngine;

public class WaveRing : MonoBehaviour
{
    public float expandSpeed = 2f;
    public float lifetime = 3f;

    private float startTime;
    private Vector3 startScale;
    private Material material;

    void Start()
    {
        startTime = Time.time;
        startScale = transform.localScale;

        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            material = renderer.material;
        }
    }

    void Update()
    {
        float elapsed = Time.time - startTime;
        float progress = elapsed / lifetime;

        transform.localScale = startScale * (1f + elapsed * expandSpeed);

        {
            Color color = material.color;
            color.a = 1f - progress;
            material.color = color;
        }

        // Destroy when done
        if (progress >= 1f)
        {
            Destroy(gameObject);
        }
    }
}