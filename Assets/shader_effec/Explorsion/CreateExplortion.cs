using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class creat : MonoBehaviour
{
    [SerializeField]
    GameObject obj;
    //[SerializeField]
    Material mat;
    List<GameObject> newobjects = new List<GameObject>();
    float passedtime ;
    GameObject newobj;
    float time =0;
    GameObject test;
    // Start is called before the first frame update
    void Start()
    {
        
        newobj = Instantiate(obj);
        //Debug.Log(mat);
    }
        
    // Update is called once per frame
    void Update()
    {
        //time +=Time.deltaTime*2.0f;
        //newobj.GetComponent<Renderer>().material.SetFloat("_Destruction",time);
        
        if(newobjects.Count!=0)
        {
            time +=Time.deltaTime*2.0f;
            foreach(GameObject x in newobjects)
            {
                x.GetComponent<Renderer>().material.SetFloat("_Destruction",time);
            }
        }
        
        
        Makefire();
        //Deletefire();
        
        
    }

    



    public void Makefire()
    {
        if(Input.GetKeyDown(KeyCode.A) || OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger) )
        {
            time =0;
            test = Instantiate(obj);
            newobjects.Add(test);
            Debug.Log(newobjects.Count);
        
        }

    }

    public void Deletefire()
    {
        if(Input.GetKeyDown(KeyCode.D) || time>1.2f    )
        {
            Destroy(test);
            newobjects.Remove(test);
            time =0;
        }
    }

    
}

