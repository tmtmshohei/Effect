using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using System;

//シェーダーとオブジェクトの橋渡しをする
public class SciFiExplosion : MonoBehaviour
{
    [SerializeField]
    private MeshRenderer meshRenderer;

    private Material material;

    private float  time;
    private float delayTime;
    
    public void Init(Color color, float life  , float speed)
    {
        //マテリアルの取得
        material = meshRenderer.material;
        time= Time.timeSinceLevelLoad;

        //シェーダーに伝える
        //material.hogehoge 
        material.SetFloat("_PassedTime",time);
        material.SetFloat("_Speed",speed);
        material.SetColor("_TintColor",color);
        Debug.Log("ScifiExplosion Color = " + color + "  life = " + life+ "speed" + speed+"color."+Color.green);


        delayTime = life;
        Observable.Return(0)
        .Delay(TimeSpan.FromSeconds(delayTime))
        .Subscribe(_ =>
        {
            //DelayTime後にやりたいこと
            //Destroyとか
            Destroy(gameObject);

        }).AddTo(this);
    }
}
