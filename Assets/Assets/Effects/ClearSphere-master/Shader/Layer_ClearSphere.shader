Shader "Unlit/Layer_ClearSphere"
{
	Properties
	{
		[HDR] _IntersectColor("Intersect Color", Color) = (0.5,0.5,0.5,0.5)
    	_IntersectPower("Intersect Power", Range(0.1,10.0)) = 1.0
    	_IntersectStep("Intersect Step", Range(2, 64)) = 20

	    [HDR] _RimColor("Rim Color", Color) = (0.5,0.5,0.5,0.5)
    	_RimPower("Rim Power", Range(0.01,10.0)) = 2.0
    	_RimStep("Rim Step", Range(0, 64)) = 4

	}

	SubShader
	{			
		Tags 
		{ 
			"Queue" = "Transparent"
  			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
      		"PreviewType" = "Sphere" 
      		"Distort" = "UVMesh"
		}

		Pass
		{
			Name "BASE"
			Tags {"LightMode" = "Always"}

			Blend SrcAlpha One
			ColorMask RGB 
			Cull Off 
			Lighting Off 
			ZWrite Off 



			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			fixed4 _IntersectColor;
			fixed  _IntersectPower;
			fixed  _IntersectStep;
			fixed4 _RimColor;
			fixed  _RimPower;
			fixed  _RimStep;


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//float4 color : COLOR;
				//float4 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 color : COLOR;
				float4 projPos : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : NORMAL;
				//float4 uv : TEXCOORD4;

				UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
					
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				
				UNITY_SETUP_INSTANCE_ID(v);
    			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//オブジェクト変換+ビュー変換+プロジェクション変換を行なった結果(クリッピング空間座標)を代入
				o.vertex = UnityObjectToClipPos(v.vertex);
				//オブジェクト変換の計算を実行結果を代入
				o.worldPos = mul(unity_ObjectToWorld , v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//スクリーン空間座標を代入
				//1. オブジェクトのメッシュに対して、ComputeScreenPos() で画面上に対応する座標を取得
				//座標系の修正をしている(xy座標に対して)
				o.projPos = ComputeScreenPos(o.vertex);
				//o.uv = v.uv;
				//o.color = v.color;
					
				//2. COMPUTE_EYEDEPTH() でカメラからみた深度を計算
				//座標系の修正をしている(z座標に対して)→これでprojPosはカメラから見た座標を正確に画面に写せる
				//ここまでは画面UVの計算?
				COMPUTE_EYEDEPTH(o.projPos.z);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			//プライマリカメラからの描画済みの深度テクスチャの取得
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			
			fixed4 frag (v2f i) : SV_Target
			{
				float ndotv_org = dot(i.worldNormal,normalize(i.viewDir));
				float ndotv = 1 - abs(ndotv_org);
				//3. 1 を使って _CameraDepthTexture をデコードし、描画済オブジェクトのカメラからの深度を取得
				float scenez = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.projPos)));
				//描画済みのオブジェクトの深度からこのシェーダーマテリアルがアタッチされているオブジェクトの深度を減算している
				float intersect = pow(saturate( 1-(scenez - i.projPos.z)),_IntersectPower);
				intersect = floor(intersect * _IntersectStep) / _IntersectStep;

				float rim = saturate(ndotv);
				rim = pow(rim,_RimPower);

				fixed4 col = _RimColor*rim;
				//ndotv = 1 - max(0,ndotv_org);
				col = col + (_IntersectColor*intersect);
				
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0, 0, 0, 0));
          		return (col);
					
			}
			ENDCG
		}
	}
}
