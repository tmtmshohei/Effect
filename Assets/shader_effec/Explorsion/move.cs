using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class move : MonoBehaviour
{

    [SerializeField]
    private EffectFactory effectFactory;

    
    [SerializeField]
    private Color color = Color.blue;

    [SerializeField]
    private float size = 1f;
    [SerializeField]
    private float speed = 1.5f;


    private Rigidbody rb;


    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.AddForce(transform.forward*30);
    }

    // Update is called once per frame
    void Update()
    {
        //if(Input.GetKeyDown(KeyCode.A))
        //{
            
        //}
    }

    void OnCollisionEnter(Collision collisionInfo)
    {
        Debug.Log("hit");
        effectFactory.CreateEffect(color, size,speed);
    }
}
