using TMPro;
using UnityEngine;

/// <summary>
/// ~  Fps counter for unity  ~
/// Brief : Calculate the FPS and display it on the screen 
/// HowTo : Create empty object at initial scene and attach this script!!!
/// </summary>
public class FPSCounterView : MonoBehaviour
{
    [SerializeField]
    private TMP_Text text;

    // for fps calculation.
    private int frameCount;
    private float elapsedTime;
    private double frameRate;


    /// <summary>
    /// Monitor changes in resolution and calcurate FPS
    /// </summary>
    private void Update()
    {
        // FPS calculation
        frameCount++;
        elapsedTime += Time.deltaTime;
        if (elapsedTime > 0.5f)
        {
            frameRate = System.Math.Round(frameCount / elapsedTime, 1, System.MidpointRounding.AwayFromZero);
            frameCount = 0;
            elapsedTime = 0;

            text.text = frameRate.ToString("F1") + "fps";

        }

    }
}