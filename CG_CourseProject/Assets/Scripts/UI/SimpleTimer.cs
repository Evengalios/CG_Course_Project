using UnityEngine;
using TMPro;

public class SimpleTimer : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI timerText;

    private float elapsedTime = 0f;

    void Update()
    {
        elapsedTime += Time.deltaTime;
        UpdateTimerDisplay();
    }

    void UpdateTimerDisplay()
    {
        int minutes = Mathf.FloorToInt(elapsedTime / 60f);
        int seconds = Mathf.FloorToInt(elapsedTime % 60f);
        int milliseconds = Mathf.FloorToInt((elapsedTime * 100f) % 100f);

        timerText.text = string.Format("{0:00}:{1:00}:{2:00}", minutes, seconds, milliseconds);
    }

    // Optional: Call this to reset the timer
    public void ResetTimer()
    {
        elapsedTime = 0f;
    }

    // Optional: Call this to stop the timer
    public void StopTimer()
    {
        enabled = false;
    }

    // Optional: Call this to resume the timer
    public void ResumeTimer()
    {
        enabled = true;
    }

    // Get the current elapsed time
    public float GetElapsedTime()
    {
        return elapsedTime;
    }
}