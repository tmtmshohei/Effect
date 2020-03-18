Shader "Unlit/Unlit_VAT_Wave"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap ("Normal map", 2D) = "bump" {}
		_Shininess ("Shininess", Range(0.0, 1.0)) = 0.078125
		_color("color",Color)=(1,1,1,1)
		_heighlight("HeighLight",2D) = "white"{}
		
		_heiglightintensity("ハイライトの強度",Float) = 0
		_perFrame("フレーム間隔",Float) = 0.03
		_row("行",Int) = 4
		_colum("列",Int) = 4
		_F0("F0",Range(0,1))=0
		_test("Test",2D) = "white"{}


		_boundingMax("Bounding Max", Float) = 1.0
		_boundingMin("Bounding Min", Float) = 1.0
		_numOfFrames("Number Of Frames", int) = 240
		_speed("Speed", Float) = 0.33
		[MaterialToggle] _pack_normal ("Pack Normal", Float) = 0
		_posTex ("Position Map (RGB)", 2D) = "white" {}
		_nTex ("Normal Map (RGB)", 2D) = "grey" {}

	}
	SubShader {

		Tags { "Queue"="Transparent" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			float4 _LightColor0;
			sampler2D _MainTex;
			float4  _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			half _Shininess;
			float4 _color;
			sampler2D _heighlight;
			float4 _heighlight_ST;
			float _heiglightintensity;
			float _perFrame;
			int _row;
			int _colum;
			float _F0;
			sampler2D _test;
			sampler2D _posTex;
			sampler2D _nTex;
			uniform float _pack_normal;
			uniform float _boundingMax;
			uniform float _boundingMin;
			uniform float _speed;
			uniform int _numOfFrames;

			float4 hoge(sampler2D tex ,float2 uv, int index, float dx, float dy)
			{
				float2 nuv = float2(uv.x*dx + fmod(index,_row)*dx , 1-(uv.y*dy+(index/_colum)*dy	));
				float4 col = tex2D(tex,nuv);
				return col;
			}

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				// 頂点の法線と接線の情報を取得できるようにする
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 vat : TEXCOORD1;
				
			};

			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 lightDir : TEXCOORD1;
				half3 viewDir : TEXCOORD2;
				float2 nuv : TEXCOORD3;
				float2 huv : TEXCOORD4;
				float vdotn : TEXCOORD6;
				float3 worldPos : TEXCOORD7;
				float3 worldNormal : TEXCOORD8;
				float2 vat : TEXCOORD9;
			};

			v2f vert(appdata v) {
				v2f o;
				float yoffset = sin(v.vertex.x)+sin(v.vertex.z);
				//v.vertex.y += yoffset*frac(_Time.y);
				
				o.uv  = TRANSFORM_TEX(v.texcoord, _MainTex);//v.texcoord.xy;
				o.nuv = TRANSFORM_TEX(v.texcoord, _NormalMap);
				o.huv = TRANSFORM_TEX(v.texcoord, _heighlight);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				// 接空間におけるライト方向のベクトルと視点方向のベクトルを求める
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				float3 viewdir = normalize(ObjSpaceViewDir(v.vertex));
				o.vdotn = dot(viewdir,v.normal);
				//ここから下はVAT移植
				float timeInFrames = ((ceil(frac(-_Time.y * _speed) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);
				float4 texturePos = tex2Dlod(_posTex,float4(v.vat.x, (timeInFrames + v.vat.y ), 0, 0));
				float3 textureN = tex2Dlod(_nTex,float4(v.vat.x, (timeInFrames + v.vat.y ), 0, 0));
				float expand = _boundingMax - _boundingMin;
				texturePos.xyz *= expand;
				texturePos.xyz += _boundingMin;
				texturePos.x *= -1;  //flipped to account for right-handedness of unity
				v.vertex.xyz += texturePos.xzy;  //swizzle y and z because textures are exported with z-up
				o.pos = UnityObjectToClipPos(v.vertex);

				if (_pack_normal){
					//decode float to float2
					float alpha = texturePos.w * 1024;
					float2 f2;
					f2.x = floor(alpha / 32.0) / 31.5;
					f2.y = (alpha - (floor(alpha / 32.0)*32.0)) / 31.5;

					//decode float2 to float3
					float3 f3;
					f2 *= 4;
					f2 -= 2;
					float f2dot = dot(f2,f2);
					f3.xy = sqrt(1 - (f2dot/4.0)) * f2;
					f3.z = 1 - (f2dot/2.0);
					f3 = clamp(f3, -1.0, 1.0);
					f3 = f3.xzy;
					f3.x *= -1;
					v.normal = f3;
					} else {
					textureN = textureN.xzy;
					textureN *= 2;
					textureN -= 1;
					textureN.x *= -1; 
					v.normal = textureN;
				}
				//移植終わり

				return o;
			}

			float4 frag(v2f i) : COLOR {
				//以下Normalアニメーション用テストスクリプト
				int totalframe = _row*_colum;
				float current = fmod(_Time.y/_perFrame,totalframe);
				int index = floor(current);
				float dx = 1.0/_row;
				float dy = 1.0/_colum;
				/////////////////////////
				half fresnel = _F0 + (1.0h - _F0) * pow(1.0h - i.vdotn, 5);
				int nextframe = floor(fmod(current+1,totalframe));
				/////////////////////////


				i.lightDir = normalize(i.lightDir);
				i.viewDir = normalize(i.viewDir);
				half3 halfDir = normalize(i.lightDir + i.viewDir);

				half4 tex = tex2D(_MainTex, i.uv);

				// ノーマルマップから法線情報を取得する
				//half3 normal = UnpackNormal(tex2D(_NormalMap, i.nuv));
				half3 normal = UnpackNormal(hoge(_NormalMap, i.nuv,index,dx,dy)).xyz;
				float4 hlight = hoge(_heighlight,i.huv,index,dx,dy);
				//float4 hlight = tex2D(_heighlight,i.nuv-0.1);
				//fixed4 color = hoge(_MainTex,i.uv-0.3,index,dx,dy);
				fixed4 color = lerp(hoge(_MainTex,i.uv-0.3,index,dx,dy),hoge(_MainTex,i.uv-0.3,nextframe,dx,dy),current-nextframe);
				fixed4 colorhoge = hoge(_MainTex,i.uv,index,dx,dy);
				// ノーマルマップから得た法線情報をつかってライティング計算をする
				half4 diff = saturate(dot(normal, i.lightDir)) * _LightColor0;
				half3 spec = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb * colorhoge.rgb;
				
				//以下Normalアニメーション用テストスクリプト
				//color = hoge(_MainTex,i.uv,index,dx,dy);
				//return (fresnel).xxxx;
				/////////////////////////
				color.rgb  = color.rgb * diff + spec *0.5;//* fresnel;
				//color.rgb  = color.rgb * fresnel;
				
				color.rgba *= _color.rgba;
				//以下テスト
				//hlight = hoge(_heighlight,i.uv,index,dx,dy);
				/////

				////見る角度に応じてハイライトに強弱をつけるかどうか
				color.rgb += hlight.rgb*(spec+_heiglightintensity)*0.3;
				//color.rgb += hlight.rgb*_heiglightintensity;
				//color.rgb += hlight.rgb*(fresnel+_heiglightintensity)*0.1;
				

				//float circle = length(i.uv.x,0.5);
				//return (circle).xxxx;

				float4 test = tex2D(_test,i.uv);
				color.rgb += test.rgb*(spec+_heiglightintensity)*0.4;
				//color.rgb += test.rgb*(fresnel+_heiglightintensity)*0.4;

				half3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				half3 reflDir = reflect(-worldViewDir, i.worldNormal);
				half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, 0);

				// Reflection ProbeがHDR設定だった時に必要な処理
				refColor.rgb = DecodeHDR(refColor, unity_SpecCube0_HDR);
				
				color += refColor*0.15;

				return color;
			}

			ENDCG
		}
	}
}
