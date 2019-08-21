using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using System;

//エフェクトを初期化した上で生成して返す
public class EffectFactory : MonoBehaviour
{
    [SerializeField]
    private SciFiExplosion effectSource;

    private SciFiExplosion effect;
    private Vector3 pos;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    public SciFiExplosion CreateEffect(Color color, float life,float speed)
    {
        
        effect = Instantiate(effectSource);
        effect.Init(color, life, speed);
        return effect;
        
    }
}
