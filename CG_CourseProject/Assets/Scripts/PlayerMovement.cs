using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 5f;
    public float jumpForce = 10f;

    [Header("Ground Check")]
    public Transform groundCheck;
    public float groundCheckRadius = 0.3f;
    public LayerMask groundLayer;

    private Rigidbody rb;
    private bool isGrounded;
    private float moveInput;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        moveInput = Input.GetAxisRaw("Horizontal");

        isGrounded = Physics.CheckSphere(groundCheck.position, groundCheckRadius, groundLayer);

        if (Input.GetKeyDown(KeyCode.Space) && isGrounded)
        {
            rb.velocity = new Vector3(rb.velocity.x, jumpForce, 0);
        }
    }

    void FixedUpdate()
    {
        rb.velocity = new Vector3(moveInput * moveSpeed, rb.velocity.y, 0);
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Goal"))
        {
            GameManager.Instance.Win();
        }

        if (other.CompareTag("Enemy") || other.CompareTag("Hazard"))
        {
            GameManager.Instance.Lose();
        }

        if (other.CompareTag("Collectible"))
        {
            Destroy(other.gameObject);
            GameManager.Instance.AddScore(100);
        }
    }
}