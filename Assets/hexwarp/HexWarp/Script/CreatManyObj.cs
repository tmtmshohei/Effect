using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatManyObj : MonoBehaviour
{
    [SerializeField]
    GameObject obj;
    [SerializeField]
    GameObject obj2;
    List<GameObject> inst = new List<GameObject>();
    GameObject source;
    int frag = 0;
    public int x = 13;
    public int z = 30;

    // Use this for initialization
    void Start()
    {
        source = obj;
        for (int i = 0; i < x; i++)
        {
            for (int j = 0; j < z; j++)
            {
                inst.Add(Instantiate(source, new Vector3(i + 0.5f, 0, j + 0.5f), this.transform.rotation));
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger) || Input.GetKeyDown(KeyCode.A))
        {
            foreach (GameObject x in inst) Destroy(x);
            if (frag % 2 == 0) source = obj;
            else source = obj2;
            for (int i = 0; i < x; i++)
            {
                for (int j = 0; j < z; j++)
                {
                    inst.Add(Instantiate(source, new Vector3(i + 0.5f, 0, j + 0.5f), this.transform.rotation));
                }
            }
            frag += 1;
        }
    }
}
