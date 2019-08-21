using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class makesaber : MonoBehaviour
{
    [SerializeField]
    GameObject saber;


    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < 1000; i++)
        {
            Instantiate(saber, new Vector3(0.0f, 0.0f, (float)i * 0.2f-3.4f), Quaternion.identity);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
