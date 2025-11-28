using UnityEngine;

public class BarcodeAttack : MonoBehaviour
{
    private string currentBarcode = "";
    private Renderer objectRenderer;
    public GameObject enemyManager;



    void Update()
    {
        // Check for any key press
        if (Input.anyKeyDown)
        {

            // Get the last character pressed
            string inputChar = Input.inputString;

            // If it's not empty and not the Enter key
            if (!string.IsNullOrEmpty(inputChar) && inputChar != "\n" && inputChar != "\r")
            {
                currentBarcode += inputChar;
                Debug.Log(inputChar);
            }

        }
        // commands to destroy enemies on enter
        if (Input.GetKeyDown(KeyCode.Return))
        {
            if (currentBarcode.Contains("red"))
            {
                if (EnemyManager.Instance != null)
                {
                    EnemyManager.Instance.DestroyOldestRed();
                }
            }
            else if (currentBarcode.Contains("blue"))
            {
                if (EnemyManager.Instance != null)
                {
                    EnemyManager.Instance.DestroyOldestBlue();
                }
            }
            else if (currentBarcode.Contains("green"))
            {
                if (EnemyManager.Instance != null)
                {
                    EnemyManager.Instance.DestroyOldestGreen();
                }
            }
            else if (currentBarcode.Contains("yellow"))
            {
                if (EnemyManager.Instance != null)
                {
                    EnemyManager.Instance.DestroyOldestYellow();
                }
            }
            else
            {
                Debug.Log("no enemies of type");
            }



            Debug.Log("Scanned Barcode " + currentBarcode);
            currentBarcode = "";


        }



    }
}
