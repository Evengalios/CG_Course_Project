using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class DeathPanel : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI survivalTimeText;
    [SerializeField] private GameObject deathPanel;
    [SerializeField] private SimpleTimer timer;
    [SerializeField] private TextMeshProUGUI[] menuOptions; 
    [SerializeField] private Color selectedColor = Color.white;
    [SerializeField] private Color deselectedColor = Color.gray;

    private float survivalTime;
    private int currentSelection = 0;
    private string[] originalTexts;
    private Camera uiCamera;
    private bool panelActive = false;

    void Start()
    {
        if (deathPanel != null)
        {
            deathPanel.SetActive(false);
        }

        originalTexts = new string[menuOptions.Length];
        for (int i = 0; i < menuOptions.Length; i++)
        {
            originalTexts[i] = menuOptions[i].text.TrimStart('>', ' ').Trim();
        }

        Canvas canvas = menuOptions[0].canvas;
        uiCamera = canvas.worldCamera;
    }

    void Update()
    {
        if (panelActive)
        {
            HandleInput();
        }
    }

    void HandleInput()
    {
        // Keyboard nav
        if (Input.GetKeyDown(KeyCode.W) || Input.GetKeyDown(KeyCode.UpArrow))
        {
            currentSelection--;
            if (currentSelection < 0)
                currentSelection = menuOptions.Length - 1;
            UpdateMenuDisplay();
        }
        if (Input.GetKeyDown(KeyCode.S) || Input.GetKeyDown(KeyCode.DownArrow))
        {
            currentSelection++;
            if (currentSelection >= menuOptions.Length)
                currentSelection = 0;
            UpdateMenuDisplay();
        }

        // Mouse nav
        HandleMouseSelection();

        // Selection
        if (Input.GetKeyDown(KeyCode.Return) || Input.GetMouseButtonDown(0))
        {
            SelectOption();
        }
    }

    void HandleMouseSelection()
    {
        for (int i = 0; i < menuOptions.Length; i++)
        {
            RectTransform rectTransform = menuOptions[i].GetComponent<RectTransform>();
            if (RectTransformUtility.RectangleContainsScreenPoint(rectTransform, Input.mousePosition, uiCamera))
            {
                if (currentSelection != i)
                {
                    currentSelection = i;
                    UpdateMenuDisplay();
                }
                break;
            }
        }
    }

    void UpdateMenuDisplay()
    {
        for (int i = 0; i < menuOptions.Length; i++)
        {
            if (i == currentSelection)
            {
                menuOptions[i].text = "> " + originalTexts[i];
                menuOptions[i].color = selectedColor;
            }
            else
            {
                menuOptions[i].text = "  " + originalTexts[i];
                menuOptions[i].color = deselectedColor;
            }
        }
    }

    public void ShowDeathPanel(float timeAlive)
    {
        survivalTime = timeAlive;

        // Stop the timer
        if (timer != null)
        {
            timer.StopTimer();
        }
        int minutes = Mathf.FloorToInt(survivalTime / 60f);
        int seconds = Mathf.FloorToInt(survivalTime % 60f);
        int milliseconds = Mathf.FloorToInt((survivalTime * 100f) % 100f);

        survivalTimeText.text = "You survived for: " + string.Format("{0:00}:{1:00}:{2:00}", minutes, seconds, milliseconds);

        if (deathPanel != null)
        {
            deathPanel.SetActive(true);
        }

        currentSelection = 0;
        UpdateMenuDisplay();
        panelActive = true;
        StartCoroutine(PauseAfterAnimation());
    }

    System.Collections.IEnumerator PauseAfterAnimation()
    {

        yield return new WaitForSecondsRealtime(0.5f); 
        Time.timeScale = 0f;
    }

    void SelectOption()
    {
        switch (currentSelection)
        {
            case 0: // Play Again
                PlayAgain();
                break;
            case 1: // Main Menu
                MainMenu();
                break;
        }
    }

    // Button Methods
    public void PlayAgain()
    {
        Time.timeScale = 1f; // Unpause
        panelActive = false;
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void MainMenu()
    {
        Time.timeScale = 1f; // Unpause
        panelActive = false;
        SceneManager.LoadScene("MainMenu"); 
    }
}