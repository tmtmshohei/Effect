
using System.Collections.Generic;
using UnityEngine;
using System;


public class MenyMeshesRenderer : MonoBehaviour {

	public Shader shader;
 
	Material material;
 
	/// <summary>
	/// 初期化
	/// </summary>
	void Start () {
		material = new Material(shader);
	}
		
	/// <summary>
	/// レンダリング
	/// </summary>
	void OnRenderObject() {
 
		// レンダリングを開始
		material.SetPass(0);
 
		// 1万個のオブジェクトをレンダリング
		Graphics.DrawProcedural(MeshTopology.Points, 100);
	}
}
