Shader "HOTATE/Si-Fi-Circuit"
{
	Properties {
		_basecolor ("BaseColor",color) = (0.0,1.0,1.0,0.3)
		_pointcolor ("PointColor",color) = (1.0,0.0,0.0,1.0)
		_width ("Width",float) = 0.0001
		_pointwidth ("PointSize",float) = 0.1
		//[HideInInspector]
		_minalpha ("MinAlpha",float) = 0.01
		[HideInInspector]_size ("Size",vector) = (1.0,1.0,1.0,0.0)
		_fps ("Speed",float) = 1.0
		_cycle ("Cycle",float) = 1.0
		_interval ("Interval",float) = 10
		_TessFactor ("TesselationFactor",int) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" "PreviewType" = "Plane"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		Cull off

		Pass {
			CGPROGRAM
			#pragma vertex vert
    		#pragma hull HS
			#pragma domain DS
			#pragma geometry geom
			#pragma fragment frag


			
			#include "UnityCG.cginc"
			uniform float4 _basecolor;
			uniform float _minalpha;
			uniform float4 _pointcolor;
			uniform float _width;
			uniform float _pointwidth;
			uniform float4 _size;
			uniform float _fps;
			uniform float _cycle;
			uniform float _interval;
			uniform float _TessFactor;

			struct v2g{
				float vid : TEXCOORD;
				float4 vertex : POSITION;
			};

			struct h2d_const
			{
				float tess_factor[3] : SV_TessFactor;
				float InsideTessFactor : SV_InsideTessFactor;
			};

			struct g2f{
				float4 vertex : SV_POSITION;
				float id : TEXCOORD0;
				float prim : TEXCOORD1;
				float cameradist : TEXCOORD2;
			};
			
			v2g vert (float4 vertex : POSITION,uint vid : SV_VertexID){
				v2g o;
				o.vid = vid;
				o.vertex = vertex;
				return o;
			}

			#define INPUT_PATCH_SIZE 3
			#define OUTPUT_PATCH_SIZE 3
			h2d_const HSConst(InputPatch<v2g,INPUT_PATCH_SIZE> i) {
				h2d_const o ;
				o.tess_factor[0] = _TessFactor;
				o.tess_factor[1] = 1;
				o.tess_factor[2] = 1;
				o.InsideTessFactor = 1;
				return o;
			}

			[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[outputcontrolpoints(OUTPUT_PATCH_SIZE)]
			[patchconstantfunc("HSConst")]
			v2g HS(InputPatch<v2g, INPUT_PATCH_SIZE> i, uint id:SV_OutputControlPointID) {
				v2g o = i[id];
				return o;
			}

			[domain("tri")]
			v2g DS(h2d_const hs_const_data, const OutputPatch<v2g, OUTPUT_PATCH_SIZE> i, float3 bary:SV_DomainLocation) {
				v2g o;
				o.vid = i[0].vid*bary.x + i[1].vid*bary.y + i[2].vid*bary.z;
				o.vertex = i[0].vertex*bary.x + i[1].vertex*bary.y + i[2].vertex*bary.z;
				return o;
			}

			float rnoise(float u,float v) {
                return frac(sin(dot(float2(u,v), float2(135.45, 501.91))) * 81.97);
			}

			float calcpos(float index,float prime,float axis) {
				float TimeShift = 1.0/17.17171717;
				float PatchShift = 1.0/13.13131313;
				float AxisShift = 1.0/11.11111111;
				float output = lerp(-_size[axis],_size[axis],rnoise(index*0.5 +axis*AxisShift +prime*PatchShift ,floor(_Time.y*_fps+prime)*TimeShift));
				return output;
			}

			float3 stereocamerapos() {
                float3 cameraPos = _WorldSpaceCameraPos;
                #if defined(USING_STEREO_MATRICES)
                cameraPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5;
                #endif	
                return cameraPos;
			}

			[maxvertexcount(32)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream) {
				g2f o;
				float3 pos1;float3 pos2;
				float primID = (input[0].vid + input[1].vid + input[2].vid)/3.0;
				pos1 = float3(calcpos(0,primID,0),
							  calcpos(0,primID,1),
							  calcpos(0,primID,2));
				pos2 = float3(calcpos(1,primID,0),
							  calcpos(1,primID,1),
							  calcpos(1,primID,2));
				float3 camerapos = stereocamerapos();
				float4 pos[4];
				float4 wpos[4];
				pos[0] = mul(UNITY_MATRIX_MV,float4(pos1.x,pos1.y,pos1.z,1.0));
				pos[1] = mul(UNITY_MATRIX_MV,float4(pos1.x,pos1.y,pos2.z,1.0));
				pos[2] = mul(UNITY_MATRIX_MV,float4(pos1.x,pos2.y,pos2.z,1.0));
				pos[3] = mul(UNITY_MATRIX_MV,float4(pos2.x,pos2.y,pos2.z,1.0));
				wpos[0] = mul(UNITY_MATRIX_M,float4(pos1.x,pos1.y,pos1.z,1.0));
				wpos[1] = mul(UNITY_MATRIX_M,float4(pos1.x,pos1.y,pos2.z,1.0));
				wpos[2] = mul(UNITY_MATRIX_M,float4(pos1.x,pos2.y,pos2.z,1.0));
				wpos[3] = mul(UNITY_MATRIX_M,float4(pos2.x,pos2.y,pos2.z,1.0));
				float2 vec;
				o.prim = primID;
				[unroll]
				for(uint index=0;index<3;index++){
					vec = pos[index].xy-pos[index+1].xy;
					vec = normalize(float2(vec.y,-vec.x))*_width/2.0;
					o.id = (index)/3.0;
					o.cameradist = distance(camerapos.xyz,wpos[index].xyz);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index]+float4(_width,0.0,0.0,0.0))); outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index]-float4(_width,0.0,0.0,0.0))); outStream.Append(o);
					o.id = (index+1.0)/3.0;
					o.cameradist = distance(camerapos.xyz,wpos[index+1].xyz);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index+1]+float4(_width,0.0,0.0,0.0))); outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index+1]-float4(_width,0.0,0.0,0.0))); outStream.Append(o);
					outStream.RestartStrip();
					o.id = (index)/3.0;
					o.cameradist = distance(camerapos.xyz,wpos[index].xyz);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index]+float4(0.0,_width,0.0,0.0))); outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index]-float4(0.0,_width,0.0,0.0))); outStream.Append(o);
					o.id = (index+1.0)/3.0;
					o.cameradist = distance(camerapos.xyz,wpos[index+1].xyz);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index+1]+float4(0.0,_width,0.0,0.0))); outStream.Append(o);
					o.vertex = mul(UNITY_MATRIX_P,float4(pos[index+1]-float4(0.0,_width,0.0,0.0))); outStream.Append(o);
					outStream.RestartStrip();
				}
			}
			
			fixed4 frag (g2f i) : SV_Target {
				float alpha = pow(clamp(frac(_Time.y*_cycle-i.cameradist*_interval),_minalpha,1.0),0.5);
				fixed4 maincol = float4(_basecolor.rgb,_basecolor.a*alpha);
				float pointpos = step(i.id,frac(_Time.y*_fps+i.prim-i.id))-step(i.id,frac(_Time.y*_fps+i.prim-i.id+_pointwidth));
				fixed4 col = lerp(maincol,_pointcolor,saturate(pointpos));

				return col;
			}
			ENDCG
		}
	}
}
