using UnityEngine;

public class Collectibles : MonoBehaviour
{
    [Header("Float Settings")]
    public float floatSpeed = 2f;
    public float floatDistance = 0.5f;

    private Vector3 startPosition;

    void Start()
    {
        startPosition = transform.position;
    }

    void Update()
    {
        // Bob up and down using sine wave
        float newY = startPosition.y + Mathf.Sin(Time.time * floatSpeed) * floatDistance;
        transform.position = new Vector3(transform.position.x, newY, transform.position.z);

        // Optional: slow rotation for visual interest
        //transform.Rotate(Vector3.forward * 50f * Time.deltaTime);
    }
}