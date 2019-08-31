using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class addtime : MonoBehaviour {
    [SerializeField]
    GameObject obj;
    [SerializeField]
    Material mat;
    float passedtime;
    public float speed=1;
    Vector3 pos;
    bool isdissolved = true;


	// Use this for initialization
	void Start ()
    {
        passedtime = 0;
        setOne();
	}
	
	// Update is called once per frame
	void Update ()
    {
        //Debug.Log();

        dissolve();
        reverse();

        if(Input.GetKeyDown(KeyCode.A))
        {
            resettime();    
        }
        
    }

    void setOne()
    {
        mat.SetFloat("_threshold", 1);
    }

    void setZero()
    {
        mat.SetFloat("_threshold", 0);
    }
    
    void addTime()
    {
        passedtime += Time.deltaTime * speed;
    }
    void minuseTime()
    {

    }
    void resettime()
    {
        passedtime = 0;
    }


    void dissolve()
    {
        if (Input.GetKey(KeyCode.D) || OVRInput.Get(OVRInput.Button.One))
        {
            //addTime();
            passedtime += Time.deltaTime * speed;
            //mat.SetFloat("_threshold", (Mathf.Sin(Time.time * 3) + 1) / 2);
            mat.SetFloat("_threshold", passedtime);
            isdissolved = true;
        }
        else
        {
            
        }
        
    }

    void reverse()
    {
        if(Input.GetKey(KeyCode.R) || OVRInput.Get(OVRInput.Button.PrimaryIndexTrigger))
        {

            //addTime();
            passedtime += Time.deltaTime * speed;
            mat.SetFloat("_threshold", 1 - passedtime);
         isdissolved = false;

        }
        else
        {
            
        }
    }
}
