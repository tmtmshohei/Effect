Shader "Unlit/Raymarching_voxcel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			
			float3 mod(float3 x, float3 y) {
				return x - floor(x / y) * y;
			}

			float3 permute(float3 x) { return mod(((x*34.0) + 1.0)*x, 289.0); }

			float random(float2 st) {
				return frac(sin(dot(st.xy, float2(12.9898,78.233)))* 43758.5453123);
			}

			float sphere(float3 p)
			{
				return (length(p) - 1.8);
			}

			float dimsphere(float2 p,float r)
			{
				return length(p) - r;
			}

			float map(in float3 c)
			{
				float3 p = c +0.5;
				float3 sp = c - 0.8;
				sp.z -= 60 - frac(_Time.y)*lerp(5, 8, frac(_Time.y)) *6;//40+cos(_Time.y)*10;
				sp.x += 10;
				float3 sp2 = sp;
				sp2.x -= 20;
				sp2.z -= 80 - frac(_Time.y)*lerp(8, 10, frac(_Time.y)) * 10;
				p *= 0.1;
				//p.xz *= 0.6;

				float time = 0.5 + 0.15*_Time.y;
				float ft = frac(time);
				float it = floor(time);
				//ft = smoothstep( 0.7, 1.0, ft );
				//time = it + ft;
				float spe = 1.4;

				float f=0;

				f += length(lerp(0.2,0.3, permute(p*20. + float3(0., 1., 0.) *time*0.001)*0.005));
				//f += ;
				f += 0.25*p.y;
				f *= 1.;

				f = min(f, sphere(sp));
				f = min(f, sphere(sp2));


				//float f = mapTerrain( p ) + 0.25*p.y;

				return step(f, 0.05); //noiseがかかっている部分（0より大きいか）を返す
			}

			float3 castRay(in float3 ro, in float3 rd, inout float g)
			{
				float3 pos = floor(ro);
				float3 ri = 1.0 / rd;
				float3 rs = sign(rd);
				float3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;

				float res = -1.0;
				float3 col=(0).xxx;
				float3 mm = float3(0,0,0);
				for (int i = 0; i<64; i++)
				{
					if (map(pos)>0.1) //noiseの返り値(0 or 1 )で1の部分はnoiseがかかっている部分
					{
						res = 1.;   //その部分をres = 1　として保存
						col += float3(1.,1.,1.) * length(mm*float3(0.8,0.9,1.));
						break;
					}

					mm = step(dis.xyz, dis.yzx) * step(dis.xyz, dis.zxy);
					dis += mm * rs * ri;
					pos += mm * rs;
					g += 0.015 *rs.z ;
				}
				//
				//col = float3(1.,1.,1.) * length(mm*float3(0.3,0.7,1.));
				return col;
			}

			

			float de(float3 p , inout float g) {
				p.xy -= sin(p.z);//permute(p*sin(_Time.y*0.1)).z*0.01;
				
				float d = -length(p.xy) + 4.;// tunnel (inverted cylinder)

				p.xy += float2(cos(p.z + _Time.y)*sin(_Time.y), cos(p.z + _Time.y));
				p.z -= 6. + _Time.y * 6.;
				d = min(d, dot(p, normalize(sign(p))) - 1.); // octahedron (LJ's formula)
															 // I added this in the last 1-2 minutes, but I'm not sure if I like it actually!

															 // Trick inspired by balkhan's shadertoys.
															 // Usually, in raymarch shaders it gives a glow effect,
															 // here, it gives a colors patchwork & transparent voxels effects.
				g += .015 / (.01 + d * d);
				return d;
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 p = float2(i.uv) * 2 - 1;

				float time = 2.0*_Time.y*0.1 + 50.0;
				float3 ro = float3(0. + cos(_Time.y) * 3, -9 + sin(_Time.y) * 3, 5 * frac(_Time.y)*lerp(2,12, frac(_Time.x)));////sin( time+0.0, 1.0 );
																															  // build ray

				float3 up = float3(0.,1.,0.);
				float3 forward = float3(0.,0.,1.);
				float3 side = cross(up,forward);
				float3 rd = forward + side * p.x + up * p.y; //normalize( cam * float3(p.xy,-1.5) );
				float g = 0;

				float4 col = float4(dimsphere(p,frac(_Time.y*3.5))*0.8, 0,0.6, 1);
				col.g += dimsphere(p + 0.2, 0.1 + frac(_Time.x*-9));
				float3 rgb = castRay(ro, rd,g);

				rgb.r *= sin(rd.x - _Time.y)*.2 + sin(rd.y*.5 - _Time.y * 4);
				rgb.b *= sin(rd.x - _Time.y)*.2 + sin(rd.z*.5 - _Time.y * 2);
				col.rgb += rgb;
				col.rgb *= g * 1.6;

				return col;
			}
			ENDCG
		}
	}
}


/*fragmentshader以下　　

float2 uv = float2(i.uv) * 2 - 1;
float4 col = float4(uv.x, uv.y, 1, 0);
float3 forward = float3(0, 0, 1);
float3 up = float3(0, 1, 0);
float3 side = cross(forward, up);
float3 rd = forward + uv.x*side + uv.y*up;
float3 drd = abs(1 / rd);
float3 mask = (0).xxx;
float3 raylength = (0).xxx;
float3 pos = (0).xxx;
float3 rs = sign(rd);
float3 rgb = (0).xxx;
float g = 0;


for (int i = 0; i < 16; i++)
{
if (de(pos,  g)<0.1) //noiseの返り値(0 or 1 )で1の部分はnoiseがかかっている部分
{
//res = 1.;   //その部分をres = 1　として保存
//col.rgb += float3(1	, 1, 1)*length(mask*float3(0.8, 0.9, 1.));
//col += (1).xxxx;
break;
}
//if (wall(raylength) < 0.1)break;
mask = step(raylength, raylength.yzx) * step(raylength, raylength.zxy);
raylength += mask * drd;
pos += mask * rs;
//rgb += (1.0).xxx * length(mask*float3(0.3, 0.7, 1))*0.	1;
}
col.rgb = (1.0).xxx * length(mask*float3(1, 0.5, 0.75));
col.rgb = lerp(float3(.2, .2, .7), float3(.2, .1, .2), col);
col += g * 0.4;
col.r += sin(_Time.y)*.2 + sin(pos.z*.5 - _Time.y * 6.);;
//col *= 0.6;
//col.rgb = rgb;
return col;

*/

/*voxcel fly の fragmentshader以下　　

float2 p = float2(i.uv) * 2 - 1;

float time = 2.0*_Time.y*0.1 + 50.0;
float3 ro = float3(0. + cos(_Time.y) * 3, -9 + sin(_Time.y) * 3, 5 * frac(_Time.y)*lerp(2,12, frac(_Time.x)));////sin( time+0.0, 1.0 );
// build ray

float3 up = float3(0.,1.,0.);
float3 forward = float3(0.,0.,1.);
float3 side = cross(up,forward);
float3 rd = forward + side * p.x + up * p.y; //normalize( cam * float3(p.xy,-1.5) );
float g = 0;

float4 col = float4(dimsphere(p,frac(_Time.y*3.5))*0.8, 0,0.6, 1);
col.g += dimsphere(p + 0.2, 0.1 + frac(_Time.x*-9));
float3 rgb = castRay(ro, rd,g);

rgb.r *= sin(rd.x - _Time.y)*.2 + sin(rd.y*.5 - _Time.y * 4);
rgb.b *= sin(rd.x - _Time.y)*.2 + sin(rd.z*.5 - _Time.y * 2);
col.rgb += rgb;
col.rgb *= g * 1.6;

return col;



*/