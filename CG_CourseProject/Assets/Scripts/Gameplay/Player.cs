using UnityEngine;
using System.Linq;

public class Player : MonoBehaviour
{
    public int health = 3;
    public string[] enemyTags = { "redEnemy", "blueEnemy", "greenEnemy", "yellowEnemy" };
    public float rotationSpeed = 5f;

    private DeathPanel deathPanel;
    private SimpleTimer timer;
    private HealthUI healthUI;
    private bool isDead = false;

    void Start()
    {
        // Find the death panel, timer, and health UI in the scene
        deathPanel = FindObjectOfType<DeathPanel>();
        timer = FindObjectOfType<SimpleTimer>();
        healthUI = FindObjectOfType<HealthUI>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (isDead) return; // Don't take damage if already dead

        if (collision.gameObject.tag == "redEnemy" || collision.gameObject.tag == "blueEnemy" ||
            collision.gameObject.tag == "greenEnemy" || collision.gameObject.tag == "yellowEnemy")
        {
            health -= 1;

            // Update health UI
            if (healthUI != null)
            {
                healthUI.LoseHealth();
            }

            Destroy(collision.gameObject);

            // Check if player died
            if (health <= 0)
            {
                Die();
            }
        }
    }

    private void Update()
    {
        if (isDead) return; // Stop all player behavior when dead

        GameObject closestEnemy = FindClosestEnemy();
        if (closestEnemy != null)
        {
            // Get the direction to the enemy
            Vector3 direction = (closestEnemy.transform.position - transform.position).normalized;
            // Keep the player facing horizontally only (optional)
            direction.y = 0f;
            // Smoothly rotate toward the enemy
            if (direction != Vector3.zero)
            {
                Quaternion lookRotation = Quaternion.LookRotation(direction);
                transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * rotationSpeed);
            }
        }
    }

    void Die()
    {
        isDead = true;

        // Get the elapsed time from the timer
        float survivalTime = 0f;
        if (timer != null)
        {
            survivalTime = timer.GetElapsedTime();
        }

        // Show the death panel
        if (deathPanel != null)
        {
            deathPanel.ShowDeathPanel(survivalTime);
        }

        // Optional: Hide or disable the player
        // gameObject.SetActive(false);
    }

    GameObject FindClosestEnemy()
    {
        GameObject closest = null;
        float minDistance = Mathf.Infinity;
        Vector3 currentPosition = transform.position;
        foreach (string tag in enemyTags)
        {
            GameObject[] enemies = GameObject.FindGameObjectsWithTag(tag);
            foreach (GameObject enemy in enemies)
            {
                float distance = Vector3.Distance(enemy.transform.position, currentPosition);
                if (distance < minDistance)
                {
                    closest = enemy;
                    minDistance = distance;
                }
            }
        }
        return closest;
    }
}