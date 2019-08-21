using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ImageEffect : MonoBehaviour
{
    /// <summary>
    /// コマンドバッファ名
    /// </summary>
    private const string CommandBufferName = "StencilImageEffect";

    /// <summary>
    /// イメージエフェクトで使用するマテリアル
    /// </summary>
    [SerializeField] private Material material;

    /// <summary>
    /// イメージエフェクト用コマンドバッファ
    /// </summary>
    private CommandBuffer commandBuffer;


    private void Update()
    {
        if (material == null) return;
        if (commandBuffer != null) return;

        var cam = GetComponent<Camera>();
        var cbs = cam.GetCommandBuffers(CameraEvent.BeforeImageEffects);
        foreach (var cb in cbs)
        {
            // 多重登録を回避するため、名前でチェック
            if (cb.name == CommandBufferName) return;
        }

        commandBuffer = new CommandBuffer();
        commandBuffer.name = CommandBufferName;

        // Blitでmaterialを適用してイメージエフェクトをかける
        commandBuffer.Blit(
            BuiltinRenderTextureType.CameraTarget,
            BuiltinRenderTextureType.CameraTarget,
            material);

        // カメラにコマンドバッファを登録
        cam.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }

    private void OnDisable()
    {
        if (commandBuffer == null) return;

        var cam = GetComponent<Camera>();
        cam.RemoveCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
        commandBuffer = null;
    }
}