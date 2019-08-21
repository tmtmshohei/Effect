using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicCircletest : MonoBehaviour
{
    [SerializeField]
    MagicCast obj;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update ()
    {
	    if(Input.GetKeyDown(KeyCode.A))
        {
            StartCoroutine(obj.MagicCasting());
        }
        if (Input.GetKeyDown(KeyCode.D)) StartCoroutine(obj.MagicCastEnd());
	}
}
