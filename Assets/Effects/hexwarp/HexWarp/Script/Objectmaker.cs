using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Objectmaker : MonoBehaviour
{
    [SerializeField]
    GameObject objSource;
    [SerializeField]
    GameObject objSource2;
    float passedTime;
    List<GameObject> obj;
    GameObject objchange;
    int count = 0;
    // Use this for initialization
    void Start()
    {
        passedTime = 0;
        obj = new List<GameObject>();
        objchange = Instantiate(objSource, this.gameObject.transform);

    }

    // Update is called once per frame
    void Update()
    {
        passedTime += Time.deltaTime;
        //Make();
        Change();


    }

    void Make()
    {
        if (OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger) || Input.GetKeyDown(KeyCode.A))
        {

            obj.Add(Instantiate(objSource, this.gameObject.transform));

        }
        if (passedTime > 15)
        {
            if (obj == null) return;
            foreach (GameObject x in obj)
            {
                Destroy(x);
            }
            passedTime = 0;
        }
    }

    void Change()
    {
        if (OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger) || Input.GetKeyDown(KeyCode.A))
        {

            if (count % 2 == 0)
            {
                if (objchange == null) return;
                Destroy(objchange);
                objchange = Instantiate(objSource, this.gameObject.transform);
                count += 1;
            }
            else
            {
                if (objchange == null) return;
                Destroy(objchange);
                objchange = Instantiate(objSource2, this.gameObject.transform);
                count += 1;

            }

        }
    }
}
