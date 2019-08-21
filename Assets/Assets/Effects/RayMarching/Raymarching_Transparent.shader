Shader "Unlit/Raymarching_Transparent"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			float sdSphere(float3 p,float r)
			{
				return length(p) - r;
			}
			
			float2 sphere(float2 p,float r)
			{
				return float2(length(p),r);
			}
		


			float3 hash33(float3 p)
			{

			float n = sin(dot(p, float3(7, 157, 113)));
			return frac(float3(2097152, 262144, 32768)*n);
			}
			float2 rot(float2 p, float a)
			{
				return float2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
			}

			float map(float3 p) {

				
				// Creating the repeat cubes, with slightly convex faces. Standard,
				// flat faced cubes don't capture the light quite as well.

				// Cube center offset, to create a bit of disorder, which breaks the
				// space up a little.
				float3 o = hash33(floor(p))*0.2;

				// 3D space repetition.
				p = frac(p + o) -.5;


				//
				// A bit of roundness. Used to give the cube faces a touch of convexity.
				float r = dot(p, p) - 0.21;

				// Max of abs(x), abs(y) and abs(z) minus a constant gives a cube.
				// Adding a little bit of "r," above, rounds off the surfaces a bit.
				p = abs(p);


				return max(max(p.x, p.y), p.z)*.95 + r * 0.05 - 0.21;


				// Alternative. Egg shapes... kind of.
				//float perturb = sin(p.x*10.)*sin(p.y*10.)*sin(p.z*10.);
				//p += hash33(floor(p))*.2;
				//return length(fract(p)-.5)-0.25 + perturb*0.05;

			}

			float sdBox(float3 p, float3 b)
			{
				float3 d = abs(p) - b;
				return length(max(d, 0.0))
					+ min(max(d.x, max(d.y, d.z)), 0.0); // remove this line for an only partially signed sdf 
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
				float2 uv = float2(i.uv) * 2 - 1;
				float3 rgb = float3(uv.x, uv.y, 0);//float3(0, 0, 0);//
				float4 col = float4(float3(1,1,1), 1);
				
				float3 cam = float3(0, 0, 5	*_Time.y);
				//float a = hash33(float3(_Time.y)).x;
				cam.yz = rot(cam.yz, _Time.x*0.0001);
				cam.xz = rot(cam.xz, _Time.x*0.001);
				float3 up = float3(0, 1, 0);
				float3 forward = float3(0, 0, 1);
				float3 side = cross(up, forward);
				float3 raypos = cam;
				float3 raydir = uv.x*side + uv.y*up + forward;
				float raylength = 0;
				float d;
				float thD = .035;
				float aD;
				
				for (int i = 0; i<64; i++) {

					// Break conditions. Anything that can help you bail early usually increases frame rate.
					//if(layers>15. || col.x>1. || t>10.) break;

					// Current ray postion. Slightly redundant here, but sometimes you may wish to reuse
					// it during the accumulation stage.
					

					d = map(raypos); 
					raylength +=  0.05;
					// Distance to nearest point in the cube field.

									 // If we get within a certain distance of the surface, accumulate some surface values.
									 // Values further away have less influence on the total.
									 //
									 // aD - Accumulated distance. I interpolated aD on a whim (see below), because it seemed 
									 // to look nicer.
									 //
									 // 1/.(1. + t*t*.25) - Basic distance attenuation. Feel free to substitute your own.

									 // Normalized distance from the surface threshold value to our current isosurface value.
					aD = (thD - abs(d)*15. / 16.) / thD;

					// If we're within the surface threshold, accumulate some color.
					// Two "if" statements in a shader loop makes me nervous. I don't suspect there'll be any
					// problems, but if there are, let us know.
					if (aD>0.00001) {
						// Smoothly interpolate the accumulated surface distance value, then apply some
						// basic falloff (fog, if you prefer) using the camera to surface distance, "t."
						//col += aD*aD*(3. - 2.*aD)/(1. + t*t*.25)*.2; 
						rgb += 0.1;//vec3(0.5); //固定値ではなく加算にすると外側が明るくなる
								   //layers++; 
					}


					// Kind of weird the way this works. I think not allowing the ray to hone in properly is
					// the very thing that gives an even spread of values. The figures are based on a bit of 
					// knowledge versus trial and error. If you have a faster computer, feel free to tweak
					// them a bit.

					//t += max(abs(d)*.7, thD*1.5); 
					
					raypos = cam + raydir * raylength;



				}
				float2 moveuv = float2(sin(uv.x + _Time.y), uv.y+_Time.x);
				rgb.gb = sphere(moveuv,frac(_Time.y));
				//float2 d = rgb.rg;
				//float2 e = sphere(uv, 0.8);
				//float2 l = lerp()
				col.rgb = rgb;
				return col;
			}
			ENDCG
		}
	}
}
