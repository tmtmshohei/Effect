Shader "Custom/MenyMesheShader" {
	SubShader {
        Pass {
	        CGPROGRAM
	        
	        // シェーダーモデルは5.0を指定
	        #pragma target 5.0
	        
	        // シェーダー関数を設定 
	        #pragma vertex vert
			#pragma geometry geom
	        #pragma fragment frag
	         
	        #include "UnityCG.cginc"
	        
	        // 頂点シェーダからの出力
	        // 今回は頂点位置のみ
	        struct VSOut {
	            float4 pos : SV_POSITION;
	        };
	        
	        // 頂点シェーダ
			VSOut vert (uint id : SV_VertexID)
	       	{
	       		// idをx座標に代入、そのまま帰す
	            VSOut output;
	            output.pos = float4(id, 0, 0, 1);
	             
	            return output;
	       	}
	       	
	       	// ジオメトリシェーダ
		   	[maxvertexcount(4)]
		   	void geom (point VSOut input[1], inout TriangleStream<VSOut> outStream)
		   	{
		     	VSOut output;
		      	float4 pos = input[0].pos; 
		      	
		      	// 四角形になるように頂点を生産
		      	for(int x = 0; x < 2; x++)
		      	{
			      	for(int y = 0; y < 2; y++)
			      	{
			      		// 頂点座標を計算し、射影変換
				      	output.pos = pos + float4(float2(x, y) * 0.5, 0, 0);
			          	output.pos = mul (UNITY_MATRIX_VP, output.pos);
			          	
			          	// ストリームに頂点を追加
				      	outStream.Append (output);
			      	}
		      	}
		      	
		      	// トライアングルストリップを終了
		      	outStream.RestartStrip();
		   	}
			
			// ピクセルシェーダー
	        fixed4 frag (VSOut i) : COLOR
	        {
	        	// 画面座標系のx、yから色を決める
	            return float4(i.pos.rg * 0.001, 0, 1);
	        }
	         
	        ENDCG
	     } 
     }
}
