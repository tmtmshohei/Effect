using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class WindowOpen : MonoBehaviour
{
    [SerializeField]
    Material mat1;
    [SerializeField]
    Transform objpos;
    [SerializeField]
    Transform Mirrorobj;
    private float startsize = 0;
    private float passedTime;
    private float maxScale;
    // Start is called before the first frame update
    void Start()
    {
        passedTime = 0;
        mat1.SetFloat("_th",1.0f);
        objpos.transform.position = new Vector3(Mirrorobj.localScale.x*0.5f,objpos.position.y,objpos.position.z);
        objpos.transform.localScale = new Vector3(startsize,objpos.localScale.y,objpos.localScale.z);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.F)) StartCoroutine(Effect());
    }

    private IEnumerator ChangeScal()
    {
        bool check = true;
        passedTime = 0;
        objpos.transform.position = new Vector3(Mirrorobj.localScale.x*0.5f,Mirrorobj.position.y,objpos.position.z);
        objpos.transform.localScale = new Vector3(startsize,Mirrorobj.localScale.y,objpos.localScale.z);
        while (check == true)
        {
            passedTime += Time.deltaTime;
            float seed = 1.01f - passedTime;
            float scal = passedTime * Mirrorobj.localScale.x;
            maxScale = scal;
            mat1.SetFloat("_th", seed);
            objpos.localScale = new Vector3(scal, objpos.localScale.y, objpos.localScale.z);
            if (passedTime > 1)
            {
                passedTime = 0;
                break;
            }
             yield return null;
        }
       

    }
    private IEnumerator ChangePos()
    {
        
      bool check = true;
        passedTime = 0;
        while (check == true)
        {
            passedTime += Time.deltaTime*maxScale;
            float posx = maxScale*0.5f - passedTime;
            float scalx = maxScale - passedTime;
            objpos.localScale = new Vector3(scalx, Mirrorobj.localScale.y, objpos.localScale.z);
            objpos.position = new Vector3(posx,Mirrorobj.position.y,objpos.position.z);
            if (passedTime > maxScale)
            {
                passedTime = 0;
                break;
            }
             yield return null;
        }
    }

    private IEnumerator Effect()
    {   
        yield return StartCoroutine(ChangeScal());
        yield return StartCoroutine(ChangePos());
        Debug.Log("finished");
    }
}
