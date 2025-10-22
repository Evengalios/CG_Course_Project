using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro; 

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    [Header("UI")]
    public TextMeshProUGUI scoreTextInGame;  
    public GameObject winPanel;
    public TextMeshProUGUI winScoreText;     
    public Button winPlayAgainButton;
    public GameObject losePanel;
    public TextMeshProUGUI loseScoreText;    
    public Button losePlayAgainButton;

    private int score = 0;
    private bool gameEnded = false;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        winPanel.SetActive(false);
        losePanel.SetActive(false);
        UpdateScoreUI();

        winPlayAgainButton.onClick.AddListener(RestartGame);
        losePlayAgainButton.onClick.AddListener(RestartGame);
    }

    public void AddScore(int points)
    {
        score += points;
        UpdateScoreUI();
    }

    public void Win()
    {
        if (gameEnded) return;

        gameEnded = true;
        winPanel.SetActive(true);
        winScoreText.text = "Score: " + score;
        Time.timeScale = 0f;
    }

    public void Lose()
    {
        if (gameEnded) return;

        gameEnded = true;
        losePanel.SetActive(true);
        loseScoreText.text = "Score: " + score;
        Time.timeScale = 0f;
    }

    void UpdateScoreUI()
    {
        scoreTextInGame.text = "" + score;
    }

    public void RestartGame()
    {
        Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}