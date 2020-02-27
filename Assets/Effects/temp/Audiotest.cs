using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Audiotest : MonoBehaviour
{
    const double PI = System.Math.PI;
    private enum PlayState
    {
        None,
        C,
        CS,
        D,
        DS,
        E,
        F,
        FS,
        G,
        GS,
        A,
        AS,
        B,
        C2
    }

    public double gain = 1.5;
    private double increment;
    private double sampling_frequency = 48000;
    private double time;
    private PlayState playState = PlayState.None;
    private bool nowPlaying = false;
    private float fadeScale;

    void SineWave(float[] data, int channels, double frequency)
    {
        increment = frequency * 2 * PI / sampling_frequency;
        for (var i = 0; i < data.Length; i = i + channels)
        {
            time = time + increment;
            data[i] = (float)(gain * Math.Sin(time) * fadeScale);

            if (nowPlaying)
            {
                fadeScale *= 1.5f;
                if (fadeScale > 1.0f) fadeScale = 1.0f;
            }
            else
            {
                fadeScale -= .025f;
                if (fadeScale < 0.001f)
                {
                    fadeScale = 0.0f;
                    playState = PlayState.None;
                }
            }
            if (channels == 2)
                data[i + 1] = data[i];
            if (time > 2 * Math.PI)
                time = 0;
        }
    }

    void OnAudioFilterRead(float[] data, int channels)
    {
        double scale = 1;
        switch (playState)
        {
            case PlayState.C:
                SineWave(data, channels, 261.6255653005985 * scale);
                break;
            case PlayState.CS:
                SineWave(data, channels, 277.18263097687196 * scale);
                break;
            case PlayState.D:
                SineWave(data, channels, 293.66476791740746 * scale);
                break;
            case PlayState.DS:
                SineWave(data, channels, 311.1269837220808 * scale);
                break;
            case PlayState.E:
                SineWave(data, channels, 329.62755691286986 * scale);
                break;
            case PlayState.F:
                SineWave(data, channels, 349.2282314330038 * scale);
                break;
            case PlayState.FS:
                SineWave(data, channels, 369.99442271163434 * scale);
                break;
            case PlayState.G:
                SineWave(data, channels, 391.99543598174927 * scale);
                break;
            case PlayState.GS:
                SineWave(data, channels, 415.3046975799451 * scale);
                break;
            case PlayState.A:
                SineWave(data, channels, 440.0 * scale);
                break;
            case PlayState.AS:
                SineWave(data, channels, 466.1637615180899 * scale);
                break;
            case PlayState.B:
                SineWave(data, channels, 493.8833012561241 * scale);
                break;
            case PlayState.C2:
                SineWave(data, channels, 523.2511306011974 * scale);
                break;
        }
    }

    void Play(PlayState playState_)
    {
        if (playState == PlayState.None)
        {
            fadeScale = 0.1f;
            time = 0.0f;
        }
        playState = playState_;
        nowPlaying = true;
    }

    void OnGUI()
    {
        int x = 10;
        const int dist = 50;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ド"))
        {
            Play(PlayState.C);
            Debug.Log("ド");
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ド#"))
        {
            Play(PlayState.CS);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "レ"))
        {
            Play(PlayState.D);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "レ#"))
        {
            Play(PlayState.DS);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ミ"))
        {
            Play(PlayState.E);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ﾌｧ"))
        {
            Play(PlayState.F);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ﾌｧ#"))
        {
            Play(PlayState.FS);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ソ"))
        {
            Play(PlayState.G);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ソ#"))
        {
            Play(PlayState.GS);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ラ"))
        {
            Play(PlayState.A);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ラ#"))
        {
            Play(PlayState.AS);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "シ"))
        {
            Play(PlayState.B);
        }
        x += dist;
        if (GUI.RepeatButton(new Rect(x, 10, 40, 30), "ド"))
        {
            Play(PlayState.C2);
        }
    }

    void Update()
    {
        nowPlaying = false;
        if (Input.GetKey("z"))
        {
            Play(PlayState.C);
        }
        if (Input.GetKey("s"))
        {
            Play(PlayState.CS);
        }
        if (Input.GetKey("x"))
        {
            Play(PlayState.D);
        }
        if (Input.GetKey("d"))
        {
            Play(PlayState.DS);
        }
        if (Input.GetKey("c"))
        {
            Play(PlayState.E);
        }
        if (Input.GetKey("f"))
        {
            Play(PlayState.F);
        }
        if (Input.GetKey("v"))
        {
            Play(PlayState.FS);
        }
        if (Input.GetKey("b"))
        {
            Play(PlayState.G);
        }
        if (Input.GetKey("h"))
        {
            Play(PlayState.GS);
        }
        if (Input.GetKey("n"))
        {
            Play(PlayState.A);
        }
        if (Input.GetKey("j"))
        {
            Play(PlayState.AS);
        }
        if (Input.GetKey("m"))
        {
            Play(PlayState.B);
        }
        if (Input.GetKey(","))
        {
            Play(PlayState.C2);
        }
    }
}
