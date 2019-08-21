using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Charge : MonoBehaviour {
    [SerializeField]
    GameObject charging;
    [SerializeField]
    GameObject charged;
    float passedtime=0;


	// Use this for initialization
	void Start ()
    {
		
	}

    // Update is called once per frame
    void Update()
    {
        passedtime += Time.deltaTime;
        if (passedtime > 1)
        {
            charging.SetActive(false);
            charged.SetActive(true);
        }
        if(Input.GetKeyDown(KeyCode.A))
        {
            passedtime = 0;
            Debug.Log(passedtime);
            charging.SetActive(true);
            charged.SetActive(false);
        }

    }
}
