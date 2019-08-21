using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class TestCommandBuffer : MonoBehaviour
{
    [SerializeField] Shader shader; // ポストエフェクト用のShader

    void Update()
    {
        
        if (shader == null) { return; }

        var cam = Camera.main;
        if (cam == null) { return; }

        var mat = new Material(this.shader); // Shaderからマテリアルを作成する
        var buf = new CommandBuffer();



        // 適当な名前のTemporaryRTを作成
        int temp = Shader.PropertyToID("_Temp");
        buf.GetTemporaryRT(temp, -1, -1, 0, FilterMode.Bilinear);

        // ポストエフェクトをかける
        buf.Blit(BuiltinRenderTextureType.CurrentActive, temp);
        buf.Blit(temp, BuiltinRenderTextureType.CurrentActive, mat);

        // TemporaryRTを解放
        buf.ReleaseTemporaryRT(temp);

        // カメラへCommandBufferを追加
        cam.AddCommandBuffer(CameraEvent.AfterEverything, buf);
    }
}
