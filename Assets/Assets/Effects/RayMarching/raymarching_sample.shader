
Shader "Unlit/raymarching_sample"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;


			float4 _MainTex_ST;

			float sdBox(float3 p, float s)
			{
				p = abs(p) - s;
				return max(max(p.x, p.y), p.z);
			}


			float3 mod(float3 x, float3 y) {
				return x - floor(x / y) * y;
			}

			//
			float2 rot(float2 p, float a) {
				return float2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
			}

			//距離関数 sphere
			float dSphere(float3 p) {
				float m = length(mod(p, 4) - 2) - 0.5; // modを使って繰り返し
				float s = length(p - 1) - 1.8;
				return s + step(abs(cos(_Time.y)), 0.5) * (m - s);
				
			}

			float map(float3 p) {
				float3 q = p;
				q.x -= sin(_Time.y + UNITY_PI / 2);
				//float s = dSphere(q - float3(0.5, 0.5, 0));//sdBox(q - float3(0.5, 0.5, 0.5),1)
				float s =  max(sdBox(q - float3(0.5, 0.5, 0.5), 1), +sdBox(q - float3(0.7, 0.7, 0.7), 1.5));
				return s;
			}

			//法線の計算
			float3 normal(float3 pos) {
				float2 e = float2(1.0, -1.0) * 0.5773 * 0.0001;
				return normalize(e.xyy * map(pos + e.xyy) +
					e.yyx * map(pos + e.yyx) +
					e.yxy * map(pos + e.yxy) +
					e.xxx * map(pos + e.xxx));
			}


			fixed4 frag(v2f_img i) : SV_Target
			{
				//UVを from -1 to 1 に正規化
				float2 uv = 2 * i.uv - 1;

				float2 uv2 = uv + 0.5 * sin(_Time.y) + 0.5;
				uv2.x += sin(floor(4 * uv2.y) - _Time.y);
				uv2.x += cos(floor(4 * uv2.x) + _Time.y);

				float3 p = float3(uv + step(0.4, frac(_Time.y)) * (uv2 - uv), 0);
				fixed4 col = (1).xxxx;

				float3 cam = float3(0, 1, -3);

				float3 up = normalize(float3(0,1,0));
				float3 fwd = normalize(float3(0,0,1));
				float3 side = normalize(cross(up, fwd));

				float3 rayPos = cam;
				float3 rayDir = p.x * side + p.y * up + fwd;

				float d = 0;
				float3 N;
				for (int j = 0; j < 64; j++) {
					d = map(rayPos);
					if (d < 0.0001) {
						N = normal(rayPos);
						break;
					}
					rayPos += d * rayDir;
				}

				if (d < 0.0001) {
					//ライト？
					float3 L = normalize(float3(-1.0, 0.5, -0.2));
					//レイマーチングで書き出される絵の色を決定
					float3 Lcol = lerp(float3(2.6, 2.3, 1.4), float3(1.4, 2.6, 2.0), sin(_Time.y));
					return fixed4(pow(dot(L, N) * 0.5 + 0.5, 3) * lerp(Lcol, 1.2 * Lcol, 1 * (0.1 + 0.2 * N)), 1);
				}

				col.rgb = float3(1.2 + pow(abs(uv + dot(uv, uv)), 2), pow(1 - dot(uv2, uv2), 0.2));
				col.rgb = float3(1.2 + pow(abs(uv + dot(uv, uv)), 2), pow(1 - dot(uv2, uv2),0.2));
				col.rgb = lerp(col.rgb, 1 - col.rgb, frac(_Time.y));
				return col;
				
			}
			ENDCG
		}
	}
}







/*
//UVを from -1 to 1 に正規化
float2 uv = 2 * i.uv - 1;

float2 uv2 = uv + 0.5 * sin(_Time.y) + 0.5;
uv2.x += sin(floor(4 * uv2.y) - _Time.y);
uv2.x += cos(floor(4 * uv2.x) + _Time.y);

float3 p = float3(uv + step(0.4, frac(_Time.y)) * (uv2 - uv), 0);
fixed4 col = (1).xxxx;

float3 cam = float3(0, 1, -3);

float3 up = normalize(float3(0,1,0));
float3 fwd = normalize(float3(0,0,1));
float3 side = normalize(cross(up, fwd));

float3 rayPos = cam;
float3 rayDir = p.x * side + p.y * up + fwd;

float d = 0;
float3 N;
for (int j = 0; j < 16; j++) {
d = map(rayPos);
if (d < 0.0001) {
N = normal(rayPos);
break;
}
rayPos += d * rayDir;
}

if (d < 0.0001) {
//ライト？
float3 L = normalize(float3(-1.0, 0.5, -0.2));
//レイマーチングで書き出される絵の色を決定
float3 Lcol = lerp(float3(2.6, 2.3, 1.4), float3(1.4, 2.6, 2.0), sin(_Time.y));
return fixed4(pow(dot(L, N) * 0.5 + 0.5, 3) * lerp(Lcol, 1.2 * Lcol, 1 * (0.1 + 0.2 * N)), 1);
}

col.rgb = float3(1.2 + pow(abs(uv + dot(uv, uv)), 2), pow(1 - dot(uv2, uv2), 0.2));
col.rgb = float3(1.2 + pow(abs(uv + dot(uv, uv)), 2), pow(1 - dot(uv2, uv2),0.2));
col.rgb = lerp(col.rgb, 1 - col.rgb, frac(_Time.y));
return col;




*/