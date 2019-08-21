using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class MagicCast : MonoBehaviour
{
    [SerializeField]
    GameObject MagicCircleobj;
    [SerializeField]
    GameObject spiral;
    [SerializeField]
    GameObject thunder;
    //[SerializeField]
    //GameObject MagicCircleobj1;
    public float appearduration = 0.5f;
    public float disappearduration = 0.5f;
    public Vector3 size = new Vector3(1, 1, 1);
    public Vector3 rotation = new Vector3(0, 0, 180);
    

    IEnumerator   MagicCircleAppear()
    {
        MagicCircleobj.SetActive(true);
        Sequence sequence = DOTween.Sequence();
        sequence.Append(MagicCircleobj.transform.DOScale(size, appearduration));
        sequence.Join(MagicCircleobj.transform.DORotate(rotation, appearduration*8));
        // sequence.Append(MagicCircleobj1.transform.DOScale(new Vector3(1, 1, 1), duration));
        //sequence.Append(MagicCircleobj.transform.DORotate(new Vector3(0, 0, 90), 2));
        yield return sequence.Play().WaitForCompletion();
 
        
    }

    IEnumerator MagicCircleDisappear()
    {
        Sequence sequence = DOTween.Sequence();
        sequence.Append(MagicCircleobj.transform.DOScale(Vector3.zero, disappearduration));
        sequence.Append(MagicCircleobj.transform.DORotate(new Vector3(0,0,0), disappearduration));
        yield return sequence.Play().WaitForCompletion();
        MagicCircleobj.SetActive(false);
       // sequence.Join(MagicCircleobj1.transform.DOScale(Vector3.zero, 1));
    }

    IEnumerator SpiralAndCastAppear()
    {
        thunder.SetActive(true);
        yield return new WaitForSeconds(0.5f);
        spiral.SetActive(true);

    }
    IEnumerator SpiralAndCastDisappear()
    {
        thunder.SetActive(false);
        yield return new WaitForSeconds(0.1f);
        spiral.SetActive(false);

    }

    public IEnumerator MagicCasting()
    {
        yield return StartCoroutine(SpiralAndCastAppear());
        yield return new WaitForSeconds(1f);
        yield return StartCoroutine(MagicCircleAppear());
            
    }

    public IEnumerator MagicCastEnd()
    {
        yield return StartCoroutine(MagicCircleDisappear());
        yield return StartCoroutine(SpiralAndCastDisappear());
    }



}
