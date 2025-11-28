using UnityEngine;
using TMPro;

public class FlickeringText : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI titleText;
    [SerializeField] private float flickerSpeed = 0.08f;
    [SerializeField] private float flickerIntensity = 0.5f;
    [SerializeField] private float joltSpeed = 0.15f;
    [SerializeField] private float joltAmount = 3f;
    [SerializeField] private float staticSpeed = 0.03f;
    [SerializeField] private float staticIntensity = 0.15f;


    private int[] flickeringCharIndices = { 1, 4, 6, 8, 9, 12 }; // o, t, F, c, t, y

    private float flickerTimer = 0f;
    private float joltTimer = 0f;
    private float staticTimer = 0f;
    private Color originalColor;
    private Vector3 originalPosition;
    private Color32[] originalColors;

    void Start()
    {
        originalColor = titleText.color;
        originalPosition = titleText.rectTransform.localPosition;

        titleText.ForceMeshUpdate();
        originalColors = titleText.textInfo.meshInfo[0].colors32;
    }

    void Update()
    {
        flickerTimer += Time.deltaTime;
        if (flickerTimer >= flickerSpeed)
        {
            if (Random.value > 0.7f) 
            {
                FlickerSpecificLetters();
            }
            flickerTimer = 0f;
        }

        joltTimer += Time.deltaTime;
        if (joltTimer >= joltSpeed)
        {
            if (Random.value > 0.9f) 
            {
                float randomJoltX = Random.Range(-joltAmount, joltAmount);
                float randomJoltY = Random.Range(-joltAmount * 0.5f, joltAmount * 0.5f);
                titleText.rectTransform.localPosition = originalPosition + new Vector3(randomJoltX, randomJoltY, 0);
            }
            else
            {
                titleText.rectTransform.localPosition = originalPosition;
            }

            joltTimer = 0f;
        }

        HandleStaticEffect();
    }

    void FlickerSpecificLetters()
    {
        titleText.ForceMeshUpdate();
        var textInfo = titleText.textInfo;

        for (int i = 0; i < textInfo.characterCount; i++)
        {
            bool shouldFlicker = false;

            foreach (int flickerIndex in flickeringCharIndices)
            {
                if (i == flickerIndex)
                {
                    shouldFlicker = true;
                    break;
                }
            }

            if (shouldFlicker)
            {
                int materialIndex = textInfo.characterInfo[i].materialReferenceIndex;
                int vertexIndex = textInfo.characterInfo[i].vertexIndex;
                Color32[] colors = textInfo.meshInfo[materialIndex].colors32;

                if (Random.value > 0.6f)
                {
                    Color32 flickerColor = originalColors[vertexIndex];
                    flickerColor.a = (byte)(flickerIntensity * 255);

                    colors[vertexIndex] = flickerColor;
                    colors[vertexIndex + 1] = flickerColor;
                    colors[vertexIndex + 2] = flickerColor;
                    colors[vertexIndex + 3] = flickerColor;
                }
                else
                {
                    colors[vertexIndex] = originalColors[vertexIndex];
                    colors[vertexIndex + 1] = originalColors[vertexIndex + 1];
                    colors[vertexIndex + 2] = originalColors[vertexIndex + 2];
                    colors[vertexIndex + 3] = originalColors[vertexIndex + 3];
                }
            }
        }

        titleText.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
    }

    void HandleStaticEffect()
    {
        staticTimer += Time.deltaTime;

        if (staticTimer >= staticSpeed)
        {
            titleText.ForceMeshUpdate();
            Mesh mesh = titleText.mesh;
            Vector3[] vertices = mesh.vertices;

            float staticProgress = (Time.time * 3f) % 1f;
            float staticLineY = Mathf.Lerp(20f, -20f, staticProgress);

            for (int i = 0; i < vertices.Length; i++)
            {
                if (Mathf.Abs(vertices[i].y - staticLineY) < 2f)
                {
                    vertices[i].x += Random.Range(-staticIntensity, staticIntensity);
                }
            }

            mesh.vertices = vertices;
            titleText.canvasRenderer.SetMesh(mesh);

            staticTimer = 0f;
        }
    }
}