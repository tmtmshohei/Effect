using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//作成スクリプトを実行する
public class EffectInput : MonoBehaviour
{
    [SerializeField]
    private EffectFactory effectFactory;

    
    [SerializeField]
    private Color color = Color.green;

    [SerializeField]
    private float life = 0.7f;
    [SerializeField]
    private float speed = 1.2f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.S))
        {
            effectFactory.CreateEffect(color, life,speed);
        }
    }
}
