using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireWorksDemo : MonoBehaviour
{

    [SerializeField] ParticleSystem fireworks01;
    [SerializeField] ParticleSystem fireworks02;
    [SerializeField] ParticleSystem fireworks03;

    bool isPlaying = false;
    public float waitTime = 5;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A) && isPlaying == false)
        {

            StartCoroutine(Hoge(fireworks01, fireworks02, fireworks03));


        }
    }

    IEnumerator Hoge(ParticleSystem a, ParticleSystem b, ParticleSystem c)
    {
        isPlaying = true;
        yield return StartCoroutine(ParticleStart(a));
        yield return StartCoroutine(ParticleStart(b));
        yield return StartCoroutine(ParticleStart(c));
        isPlaying = false;
    }
    IEnumerator ParticleStart(ParticleSystem a)
    {
        PlayFireWorks(a);
        yield return new WaitForSeconds(waitTime);
    }

    void PlayFireWorks(ParticleSystem P)
    {
        P.Play();
    }
}
