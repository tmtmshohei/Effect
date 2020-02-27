using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugParam : MonoBehaviour
{

    [SerializeField]
    Material mat;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.D))
        {
            Debug.Log(mat.color);
            Debug.Log(mat.GetFloat("_camposz"));
        }
    }
}
