using UnityEngine;

public class HealthUI : MonoBehaviour
{
    [SerializeField] private Animator[] hearts; 
    [SerializeField] private float animationOffset = 0.1f; 

    private int currentHealth = 3;

    void Start()
    {
        for (int i = 0; i < hearts.Length; i++)
        {
            hearts[i].Play("HeartIdleFull", 0, i * animationOffset);
        }
    }

    public void LoseHealth()
    {
        if (currentHealth > 0)
        {
            currentHealth--;

            hearts[currentHealth].SetTrigger("Hit");
        }
    }

    public int GetCurrentHealth()
    {
        return currentHealth;
    }

    public bool IsDead()
    {
        return currentHealth <= 0;
    }
}