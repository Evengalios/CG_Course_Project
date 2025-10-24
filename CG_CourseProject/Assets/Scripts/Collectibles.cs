using UnityEngine;

public class Collectibles : MonoBehaviour
{
    [Header("Float Settings")]
    public float floatSpeed = 2f;
    public float floatDistance = 0.5f;

    [Header("Audio")]
    public AudioClip collectSound;

    private Vector3 startPosition;
    private AudioSource audioSource;

    void Start()
    {
        startPosition = transform.position;
        audioSource = gameObject.AddComponent<AudioSource>();
        audioSource.playOnAwake = false;
    }

    void Update()
    {
        float newY = startPosition.y + Mathf.Sin(Time.time * floatSpeed) * floatDistance;
        transform.position = new Vector3(transform.position.x, newY, transform.position.z);
    }

    void OnTriggerEnter(Collider collision)
    {
        if (collision.CompareTag("Player"))
        {
            AudioSource.PlayClipAtPoint(collectSound, transform.position);
            GameManager.Instance.AddScore(100);
            GetComponent<Collider>().enabled = false;
            GetComponent<MeshRenderer>().enabled = false;
            Destroy(gameObject, 0.5f);
        }
    }
}