using System.Collections;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class TypewriterEffect : MonoBehaviour
{
    [Header("Text Components")]
    [SerializeField] private TextMeshProUGUI loreText;
    [SerializeField] private TextMeshProUGUI continueText;

    [Header("Typewriter Settings")]
    [SerializeField] private float typingSpeed = 0.05f;
    [SerializeField] private float pauseDuration = 0.3f;
    [SerializeField] private string pauseCharacters = ".,!?;:";

    [Header("Cursor Settings")]
    [SerializeField] private float cursorBlinkSpeed = 0.5f;
    [SerializeField] private string cursorSymbol = "_";

    [Header("Continue Prompt Settings")]
    [SerializeField] private float continueFlashSpeed = 0.8f;

    [Header("Lore Content")]
    [TextArea(5, 15)]
    [SerializeField] private string loreContent = "Production Line 7... Sector C...\n\nUnit #4892. Defective.\n\nThe diagnosis was immediate. A glitch in your core programming. A flaw that made you... different.\n\nIn the sterile halls of the automated factory, there is no room for imperfection.\n\nThe other units received their directive: Terminate the anomaly.\n\nBut you were given something they weren't... a scanner. Your only tool. Your only weapon.\n\nEach robot bears identifiers - colored symbols that mark their function, their purpose.\n\nYour scanner can read them. Exploit them. Destroy them.\n\nThey're coming from every direction now.\n\nSurvival is your only protocol.\n\nHow long can a defect last in a world designed for perfection?";

    [Header("Scene Management")]
    [SerializeField] private string nextSceneName = "MainGame";
    [SerializeField] private bool useAnyKey = true;
    [SerializeField] private GameObject exitAnimation;
    [SerializeField] private float exitDelay = 1f;

    private bool isTyping = false;
    private bool typingComplete = false;
    private Coroutine cursorBlinkCoroutine;

    void Start()
    {
        if (loreText == null || continueText == null)
        {
            Debug.LogError("Please assign TextMeshProUGUI components in the inspector!");
            return;
        }

        loreText.text = "";
        continueText.text = "";
        continueText.alpha = 0f;

        StartCoroutine(TypeText());
    }

    void Update()
    {
        if (typingComplete && useAnyKey && Input.anyKeyDown)
        {
            StartCoroutine(ExitSequence());
        }
    }

    IEnumerator ExitSequence()
    {
        typingComplete = false;

        if (exitAnimation != null)
        {
            exitAnimation.SetActive(true);
        }

        yield return new WaitForSeconds(exitDelay);

        LoadNextScene();
    }

    IEnumerator TypeText()
    {
        isTyping = true;
        string displayText = "";

        cursorBlinkCoroutine = StartCoroutine(BlinkCursor());

        foreach (char character in loreContent)
        {
            displayText += character;
            loreText.text = displayText + cursorSymbol;

            if (pauseCharacters.Contains(character.ToString()))
            {
                yield return new WaitForSeconds(pauseDuration);
            }
            else
            {
                yield return new WaitForSeconds(typingSpeed);
            }
        }

        loreText.text = displayText;

        if (cursorBlinkCoroutine != null)
        {
            StopCoroutine(cursorBlinkCoroutine);
        }

        isTyping = false;
        typingComplete = true;

        continueText.text = "Press Any Button to Continue";
        StartCoroutine(FlashContinueText());
    }

    IEnumerator BlinkCursor()
    {
        while (isTyping)
        {
            yield return new WaitForSeconds(cursorBlinkSpeed);

            // Temporarily remove cursor
            string currentText = loreText.text;
            if (currentText.EndsWith(cursorSymbol))
            {
                loreText.text = currentText.Substring(0, currentText.Length - cursorSymbol.Length);
            }

            yield return new WaitForSeconds(cursorBlinkSpeed);
        }
    }

    IEnumerator FlashContinueText()
    {
        while (typingComplete)
        {
            // Fade in
            float elapsed = 0f;
            while (elapsed < continueFlashSpeed)
            {
                elapsed += Time.deltaTime;
                continueText.alpha = Mathf.Lerp(0.3f, 1f, elapsed / continueFlashSpeed);
                yield return null;
            }

            // Fade out
            elapsed = 0f;
            while (elapsed < continueFlashSpeed)
            {
                elapsed += Time.deltaTime;
                continueText.alpha = Mathf.Lerp(1f, 0.3f, elapsed / continueFlashSpeed);
                yield return null;
            }
        }
    }

    private void LoadNextScene()
    {
        if (!string.IsNullOrEmpty(nextSceneName))
        {
            SceneManager.LoadScene(nextSceneName);
        }
        else
        {
            Debug.LogWarning("Next scene name is not set!");
        }
    }
}