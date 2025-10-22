using UnityEngine;

public class RotatingObstacle : MonoBehaviour
{
    [Header("Rotation Settings")]
    public float rotationSpeed = 100f;

    void Update()
    {
        // Rotate continuously
        transform.Rotate(Vector3.forward * rotationSpeed * Time.deltaTime);
    }
}