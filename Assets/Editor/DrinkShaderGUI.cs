using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class DrinkShaderGUI : ShaderGUI {

    public enum BlendMode
    {
        Opaque,                 // 不透明
        Transparent,            // 半透明
        //Additive,               // 加算
        //AdditiveTransparent,    // 加算半透明
    }
    private MaterialProperty blendProp, cullProp, ztestProp, snapProp;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);
        //var srcblend = ShaderGUI.FindProperty("_SrcBlend", properties);
        //var texture = ShaderGUI.FindProperty("_MainTex", properties);
        Material targetmat = materialEditor.target as Material;
        //materialEditor.ShaderProperty(srcblend, "SrcBlend");
        //materialEditor.ShaderProperty(texture, "Texture");
        //var Culling = ShaderGUI.FindProperty("_Cullingmode", properties);
        //materialEditor.ShaderProperty(Culling, "CullingMode");
        var overlay = ShaderGUI.FindProperty("_Overlay", properties);
        if(overlay.floatValue==0)
        {
            targetmat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.One);
            targetmat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.Zero);
            targetmat.SetOverrideTag("RenderType", "Opaque");
            targetmat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
        }
        else 
        {
            
            //targetmat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
            //targetmat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            targetmat.SetFloat("_SrcBlend", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
            targetmat.SetFloat("_DstBlend", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            targetmat.SetOverrideTag("RenderType", "Transparent");
            targetmat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
          
           
        }
          


    }
}
