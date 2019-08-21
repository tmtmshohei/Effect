Shader "Unlit/Raymarching_01"
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
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"

	float2 sphere(float2 p,float r)
	{
		return float2(length(p),r);
	}

	float2 square(float2 p)
	{
		float d = abs(p.x) + abs(p.y);
		return float2(d, 0.9);
	}

	//--------------よく使う関数など-----------------------------------
	float3 mod(float3 x, float3 y) {
		return x - floor(x / y) * y;
	}

	//折りたたみ
	float3 fold(float3 p) {
		return mod(p, 4.4) - 2.2;
	}


	float mylength(float3 vec)
	{
		//length( )関数の中身を実装してみた
		return sqrt(pow(vec.x, 2) + pow(vec.y, 2) + pow(vec.z, 2));
	}

	float2 rot(float2 p, float a)
	{
		return float2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
	}


	float rand(float2 co)
	{
		return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
	}

	float Posterize(float In, float Steps)
	{
		return floor(In / (1 / Steps)) * (1 / Steps);
	}

	float Glith(float2 uv)
	{
		float x = 0.5;
		float y = Posterize((rand(float2(fmod(_Time.y,10),6))),300);
		float mulseed = sin(Posterize(_Time, 2) * 10);

		float stepy = step(y + 0.2,uv.y);
		float stepy2 = step(y,uv.y);
		float stepy3 = step(y + 0.3, uv.y);
		float stepy4 = step(y, uv.y);

		float stepx = step(x + 0.2, uv.x);
		float stepx2 = step(x, uv.x);


		float stepxsubst = (stepx*mulseed) - (stepx2*mulseed);
		float stepysubst = (stepy*mulseed) - (stepy2*mulseed);
		float stepysubst2 = (stepy3*mulseed) - (stepy4*mulseed);
		stepysubst = lerp(stepysubst, stepysubst2, fmod(_Time.y,100));

		//i.uv.x = Glith(i.uv);で使える
		return uv.x += stepysubst;
		//return float2(uv.x, 0);
	}



	//-------------distancefunctionシリーズ------------------------------------------------------------
	float sdSphere(float3 p , float r)
	{
		return length(p) - r;
		//return length(fold(p)) - r;
		//Pからrを半径とする円まで最短距離
	}

	float sdBox(float3 p, float b)
	{
		float3 fp = fold(p);
		float3 d = abs(fp) - float3(b,b,b);
		return length(max(d, 0.0))
			+ min(max(d.x, max(d.y, d.z)), 0.0); // remove this line for an only partially signed sdf 
	}

	float sdCone(float3 p, float2 c)
	{
		// c must be normalized
		float q = length(p.xy);
		return dot(c, float2(q, p.z));
	}

	float sdOctahedron(in float3 p, in float s)
	{
		p = abs(p);
		return (p.x + p.y + p.z - s)*0.57735027;
	}

	float sdQuad(float3 p)
	{
		return p.y;
	}
	//------------------------------------------------------------------------------------------------
	/*
	RayMarchingの仕組み
	distancefunctionはrayの先端を引数に受けて、そこから距離関数の表す形までの最短距離を返す
	rayをマーチング（進める）する　＝　rayの先端を距離関数の返す値の分だけ進める
	距離関数の返す値が限りなく0に近づく　＝　そこには物体がある
	UVを正規化した時（-1 ~ 1)
	forをループさせる回数が少ない(３回とか）時は、(0,0)である中心は描画されるが
	端っこに行くに従って描画されなくなっていく

	*/

	float3 getNormal(float3 p) {
		float d = 0.0001;
		return normalize(float3(
			sdSphere(p + float3(d, 0.0, 0.0),1) - sdSphere(p + float3(-d, 0.0, 0.0),1),
			sdSphere(p + float3(0.0, d, 0.0),1) - sdSphere(p + float3(0.0, -d, 0.0),1),
			sdSphere(p + float3(0.0, 0.0, d),1) - sdSphere(p + float3(0.0, 0.0, -d),1)
			));
	}

	float map(float3 raypos)
	{
		float e = sdBox(raypos, 1.6);
		float3 rotposxy = float3(rot(raypos.xy, 0.7),raypos.z);
		float erot = sdBox(rotposxy, 1.5);
		float d = max(sdSphere(raypos, 1.5), e);
		float drot = max(sdSphere(raypos, 1.8), erot);
		d = min(sdSphere(raypos, 0.5), d);
		d = min(d, drot);

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

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float2 uv = float2(i.uv) * 2 - 1;
		//uv.x = Glith(uv);
		/*//float3 rgb = float3(sphere(uv),0,0);
		float time = sin(_Time.y*0.5)*0.5-0.5;
		float2 d = lerp(sphere(uv), square(uv), time);
		float r = lerp(0,1, step(d.x,d.y));
		float g = lerp(lerp(0, 1, step(d.x, d.y)) - 0.2,lerp(0, 1, step(d.x, d.y))-0.3,_Time.y);
		//r = sin(_Time.y*10);
		float b = lerp(0, 1, step(d.x, d.y))-0.9;
		float3 rgb = float3(r, g, b);*/
		float3 rgb = float3(0, 0, 0);//float3(uv.x, uv.y, 0);
		float4 col = float4(rgb, 1);

		float3 cam = float3(0, 0, -3);//+sin(_Time.y)
		float3 forward = float3(0, 0, 1);
		float3 up = float3(0, 1, 0);
		float3 side = cross(forward, up);
		float3 raypos = cam;
		float3 raydir = uv.x*side + uv.y*up + forward;
		float3 accum = 0;
		float time = sin(_Time.y * 2)*0.5 - 0.5;
		//float3 lightDir = float3(-0.577, sin(_Time.y*0.2)*0.3/*0.577*/, -sin(_Time.y*0.2)*0.3);
		float3 lightDir = float3(-0.777, 1.577  , 1.177);
		float thD = .035;
		float aD = 0;


		for (int i = 0; i < 64; i++)
		{
			float3 rotpos = float3(rot(raypos.xy, _Time.y), raypos.z);
			rotpos.xz = float2(rot(raypos.xz, _Time.y));

			float box = sdBox(raypos,1.5);

			float d = map(raypos);
			//float e = map(rotpos);
			d = max(abs(d), 0.02);
			//e = max(abs(e), 0.02);
			float mo = lerp(d, box, time);		

			accum += mo;//0.05;//
			float3 normal = getNormal(raypos);
			float diff = clamp(dot(lightDir, normal), 0.1, 1.0);
			col += float4((diff).xxx, 1)*0.04;

			//aD = (thD - abs(d)*15. / 16.) / thD;
			if (box < 0.0001)
			{

				float3 normal = getNormal(raypos);
				float diff = clamp(dot(lightDir, normal), 0.1, 1.0);
				col += float4((diff).xxx, 1)*0.04;
				//rgb += 0.01;
				//break;
			}
			raypos = cam + raydir * accum;
			rotpos = cam + raydir * accum;
		}
		//col.rb = float2(sphere(float2(uv.x,uv.y),frac(_Time.x)));

		//col.rgb = rgb;
		return col;
	}
		ENDCG
	}
	}
}
