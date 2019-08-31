Shader "Unlit/Raymarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_camposz ("camposz",Float) = -3
		_Color("Debugparam",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"   }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
			float _camposz;
			float4 _Color;

			//--------------よく使う関数など-----------------------------------
			float3 mod(float3 x, float3 y) {
				return x - floor(x / y) * y;
			}

			//折りたたみ
			float3 fold(float3 p) {
				return mod(p, 4) -2		;
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

			

			//-------------distancefunctionシリーズ------------------------------------------------------------
            float sdSphere(float3 p , float r)
            {
                return mylength(p)-r;
				//return length(fold(p)) - r;
				//Pからrを半径とする円まで最短距離
            }

			float sdBox(float3 p, float b)
			{
				float3 d = abs(p) - float3(b,b,b);
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
				float2 uv = float2(i.uv.x,i.uv.y)*2-1 ;  
                float4 col = float4(uv.x,uv.y,0,1);

                float3 cam = float3(0,0,-3);
                float3 forward = float3(0,0,1);
                float3 up = float3(0,1,0);
                float3 raypos = cam;
                float3 side = cross(forward,up);
                float3 raydir = uv.x * side + uv.y * up + forward;
				float raylength = 0;
				float3 lightDir = float3(-0.577, 0.577, 0.577);
				float ac=0,accum=0;
				

                
                float d = 0 ;
                for(int i = 0; i<64 ; i++)
                {
					//raypos.xy = rot(raypos.xy,_Time.y);
					//raypos.yz = rot(raypos.yz, _Time.y);
					d = sdSphere(raypos, 1); //rayの先端からオブジェクトまでの最短距離
					//d = max(sdOctahedron(raypos, 1), -	sdBox(raypos,0.7));
					//float e = max(sdOctahedron(raypos, 1.5), -sdBox(raypos, 1.2));
					//d = min(d, e);
					
					raylength += d; //伸ばしているrayの長さ
					//d = max(abs(d), 0.02);//phantommode
					//ac += exp(-d * 3.); //phantommode
                    
                    if(abs(d)<0.00001)
                    {				
						float3 normal = getNormal(raypos);
						float diff = clamp(dot(lightDir, normal), 0.1, 1.0);
						col = float4((diff).xxx, 1);                        
                        break;
                    }
                    raypos = cam +raydir*raylength; //rayの先端
					
                }
				//col = float4((ac*0.1).xxx, 1);  //phantommode
                return col;
            }
            ENDCG
        }
    }
}
