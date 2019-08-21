Shader "Unlit/Raymarching_voxellimlight"
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
		float noise(in float3 x)
	{
		float3 p = floor(x);
		float3 f = frac(x);
		f = f * f*(3.0 - 2.0*f);

		float2 uv = (p.xy + float2(37.0,17.0)*p.z) + f.xy;
		float2 rg = float2(1, 1);//textureLod(iChannel0, (uv + 0.5) / 256.0, 0.0).yx;
		return lerp(rg.x, rg.y, f.z);
	}

	//float4 texcube(sampler2D sam, in float3 p, in float3 n)
	//{
	//	float3 m = abs(n);
	//	float4 x = texture(sam, p.yz);
	//	float4 y = texture(sam, p.zx);
	//	float4 z = texture(sam, p.xy);
	//	return x * m.x + y * m.y + z * m.z;
	//}

	float mapTerrain(float3 p)
	{
		p *= 0.1;
		p.xz *= 0.6;

		float time = 0.5 + 0.15*_Time.y;
		float ft = frac(time);
		float it = floor(time);
		ft = smoothstep(0.7, 1.0, ft);
		time = it + ft;
		float spe = 1.4;

		float f;
		f = 0.5000*noise(p*1.00 + float3(0.0,1.0,0.0)*spe*time);
		f += 0.2500*noise(p*2.02 + float3(0.0,2.0,0.0)*spe*time);
		f += 0.1250*noise(p*4.01);
		return 25.0*f - 10.0;
	}

	float3 gro = float3(0,0,0);

	float map(in float3 c)
	{
		float3 p = c + 0.5;

		float f = mapTerrain(p) + 0.25*p.y;

		f = lerp(f, 1.0, step(length(gro - p), 5.0));

		return step(f, 0.5);
	}

	float3 lig = normalize(float3(-0.4,0.3,0.7));

	float castRay(in float3 ro, in float3 rd, out float3 oVos, out float3 oDir)
	{
		float3 pos = floor(ro);
		float3 ri = 1.0 / rd;
		float3 rs = sign(rd);
		float3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;

		float res = -1.0;
		float3 mm = float3(0,0,0);
		for (int i = 0; i<128; i++)
		{
			if (map(pos)>0.5) { res = 1.0; break; }
			mm = step(dis.xyz, dis.yzx) * step(dis.xyz, dis.zxy);
			dis += mm * rs * ri;
			pos += mm * rs;
		}

		float3 nor = -mm * rs;
		float3 vos = pos;

		// intersect the cube	
		float3 mini = (pos - ro + 0.5 - 0.5*float3(rs))*ri;
		float t = max(mini.x, max(mini.y, mini.z));

		oDir = mm;
		oVos = vos;

		return t * res;
	}

	float3 path(float t, float ya)
	{
		float2 p = 100.0*sin(0.02*t*float2(1.0,1.2) + float2(0.1,0.9));
		p += 50.0*sin(0.04*t*float2(1.3,1.0) + float2(1.0,4.5));

		return float3(p.x, 18.0 + ya * 4.0*sin(0.05*t), p.y);
	}

	float3x3 setCamera(in float3 ro, in float3 ta, float cr)
	{
		float3 cw = normalize(ta - ro);
		float3 cp = float3(sin(cr), cos(cr),0.0);
		float3 cu = normalize(cross(cw,cp));
		float3 cv = normalize(cross(cu,cw));
		return float3x3(cu, cv, -cw);
	}

	float maxcomp(in float4 v)
	{
		return max(max(v.x,v.y), max(v.z,v.w));
	}

	float isEdge(in float2 uv, float4 va, float4 vb, float4 vc, float4 vd)
	{
		float2 st = 1.0 - uv;

		// edges
		float4 wb = smoothstep(0.85, 0.99, float4(uv.x,
			st.x,
			uv.y,
			st.y)) * (1.0 - va + va * vc);
		// corners
		float4 wc = smoothstep(0.85, 0.99, float4(uv.x*uv.y,
			st.x*uv.y,
			st.x*st.y,
			uv.x*st.y)) * (1.0 - vb + vd * vb);
		return maxcomp(max(wb,wc));
	}

	float calcOcc(in float2 uv, float4 va, float4 vb, float4 vc, float4 vd)
	{
		float2 st = 1.0 - uv;

		// edges
		float4 wa = float4(uv.x, st.x, uv.y, st.y) * vc;

		// corners
		float4 wb = float4(uv.x*uv.y,
			st.x*uv.y,
			st.x*st.y,
			uv.x*st.y)*vd*(1.0 - vc.xzyw)*(1.0 - vc.zywx);

		return wa.x + wa.y + wa.z + wa.w +
			wb.x + wb.y + wb.z + wb.w;
	}

	float3 render(in float3 ro, in float3 rd)
	{
		float3 col = float3(0,0,0);

		// raymarch	
		float3 vos, dir;

		float t = castRay(ro, rd, vos, dir);
		if (t>0.0)
		{
			float3 nor = -dir * sign(rd);
			float3 pos = ro + rd * t;
			float3 uvw = pos - vos;

			float3 v1 = vos + nor + dir.yzx;
			float3 v2 = vos + nor - dir.yzx;
			float3 v3 = vos + nor + dir.zxy;
			float3 v4 = vos + nor - dir.zxy;
			float3 v5 = vos + nor + dir.yzx + dir.zxy;
			float3 v6 = vos + nor - dir.yzx + dir.zxy;
			float3 v7 = vos + nor - dir.yzx - dir.zxy;
			float3 v8 = vos + nor + dir.yzx - dir.zxy;
			float3 v9 = vos + dir.yzx;
			float3 v10 = vos - dir.yzx;
			float3 v11 = vos + dir.zxy;
			float3 v12 = vos - dir.zxy;
			float3 v13 = vos + dir.yzx + dir.zxy;
			float3 v14 = vos - dir.yzx + dir.zxy;
			float3 v15 = vos - dir.yzx - dir.zxy;
			float3 v16 = vos + dir.yzx - dir.zxy;

			float4 vc = float4(map(v1),  map(v2),  map(v3),  map(v4));
			float4 vd = float4(map(v5),  map(v6),  map(v7),  map(v8));
			float4 va = float4(map(v9),  map(v10), map(v11), map(v12));
			float4 vb = float4(map(v13), map(v14), map(v15), map(v16));

			float2 uv = float2(dot(dir.yzx, uvw), dot(dir.zxy, uvw));

			// wireframe
			float www = 1.0 - isEdge(uv, va, vb, vc, vd);

			float3 wir = smoothstep(0.4, 0.5, abs(uvw - 0.5));
			float vvv = (1.0 - wir.x*wir.y)*(1.0 - wir.x*wir.z)*(1.0 - wir.y*wir.z);

			//col = 2.0*texture(iChannel1,0.01*pos.xz).zyx;
			col += 0.8*float3(0.1,0.3,0.4);
			//col *= 0.5 + 0.5*texcube(iChannel2, 0.5*pos, nor).x;
			col *= 1.0 - 0.75*(1.0 - vvv)*www;

			// lighting
			float dif = clamp(dot(nor, lig), 0.0, 1.0);
			float bac = clamp(dot(nor, normalize(lig*float3(-1.0,0.0,-1.0))), 0.0, 1.0);
			float sky = 0.5 + 0.5*nor.y;
			float amb = clamp(0.75 + pos.y / 25.0,0.0,1.0);
			float occ = 1.0;

			// ambient occlusion
			occ = calcOcc(uv, va, vb, vc, vd);
			occ = 1.0 - occ / 8.0;
			occ = occ * occ;
			occ = occ * occ;
			occ *= amb;

			// lighting
			float3 lin = float3(0,0,0);
			lin += 2.5*dif*float3(1.00,0.90,0.70)*(0.5 + 0.5*occ);
			lin += 0.5*bac*float3(0.15,0.10,0.10)*occ;
			lin += 2.0*sky*float3(0.40,0.30,0.15)*occ;

			// line glow	
			float lineglow = 0.0;
			lineglow += smoothstep(0.4, 1.0,     uv.x)*(1.0 - va.x*(1.0 - vc.x));
			lineglow += smoothstep(0.4, 1.0, 1.0 - uv.x)*(1.0 - va.y*(1.0 - vc.y));
			lineglow += smoothstep(0.4, 1.0,     uv.y)*(1.0 - va.z*(1.0 - vc.z));
			lineglow += smoothstep(0.4, 1.0, 1.0 - uv.y)*(1.0 - va.w*(1.0 - vc.w));
			lineglow += smoothstep(0.4, 1.0,      uv.y*      uv.x)*(1.0 - vb.x*(1.0 - vd.x));
			lineglow += smoothstep(0.4, 1.0,      uv.y* (1.0 - uv.x))*(1.0 - vb.y*(1.0 - vd.y));
			lineglow += smoothstep(0.4, 1.0, (1.0 - uv.y)*(1.0 - uv.x))*(1.0 - vb.z*(1.0 - vd.z));
			lineglow += smoothstep(0.4, 1.0, (1.0 - uv.y)*     uv.x)*(1.0 - vb.w*(1.0 - vd.w));

			float3 linCol = 2.0*float3(5.0,0.6,0.0);
			linCol *= (0.5 + 0.5*occ)*0.5;
			lin += 3.0*lineglow*linCol;

			col = col * lin;
			col += 8.0*linCol*float3(1.0,2.0,3.0)*(1.0 - www);//*(0.5+1.0*sha);
			col += 0.1*lineglow*linCol;
			col *= min(0.1,exp(-0.07*t));

			// blend to black & white		
			float3 col2 = float3(1.3,1.3,1.3)*(0.5 + 0.5*nor.y)*occ*www*(0.9 + 0.1*vvv)*exp(-0.04*t);;
			float mi = sin(-1.57 + 0.5*_Time.y);
			mi = smoothstep(0.70, 0.75, mi);
			col = lerp(col, col2, mi);
		}

		// gamma	
		col = pow(col, float3(0.45,0.45,0.45));

		return col;
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
				//float2 uv = float2(i.uv) * 2 - 1;
				// inputs	
				float2 q = i.uv;
			float2 p = -1.0 + 2.0*q;
			//p.x *= 1;

			float2 mo = 1/i.uv;
			//if (iMouse.w <= 0.00001) mo = float2(0.0);

			float time = 2.0*_Time.y + 50.0*mo.x;
			// camera
			float cr = 0.2*cos(0.1*_Time.y);
			float3 ro = path(time + 0.0, 1.0);
			float3 ta = path(time + 5.0, 1.0) - float3(0.0,6.0,0.0);
			gro = ro;

			float3x3 cam = setCamera(ro, ta, cr);

			// build ray
			float r2 = p.x*p.x*0.32 + p.y*p.y;
			p *= (7.0 - sqrt(37.5 - 11.5*r2)) / (r2 + 1.0);
			float3 rd =normalize(mul(cam ,float3(p.xy,-2.5)));

			float3 col = render(ro, rd);

			// vignetting	
			col *= 0.5 + 0.5*pow(16.0*q.x*q.y*(1.0 - q.x)*(1.0 - q.y), 0.1);

			 return  float4(float3(col), 1.0);
			}
			ENDCG
		}
	}
}
