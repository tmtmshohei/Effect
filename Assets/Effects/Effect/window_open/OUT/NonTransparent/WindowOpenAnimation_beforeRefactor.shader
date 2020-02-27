Shader "Unlit/windowOpenAnimation_beforeRefactor"
{
    Properties
    {
        _MainTex ("Frontfurface", 2D) = "white" {}
        _backsurface("Backsurface",2D) = "white"{}
        _monosheet("MonoSheet",2D)="white"{}
        _colsheet("ColorSheet",2D)  = "white"{}
        _perFrame("フレーム間隔",Float) = 0.016 //fps30の場合1フレームの間隔は0.033,fps60の場合0.016
		_row("行",Int) = 4
		_colum("列",Int) = 4
		_th("Threshold",Range(0,1))=0
        _uvoffset("uvXoffset",Range(0,1)) = 0.025 //境目が見えることがあるので目視で設定
        [KeywordEnum(R2L,L2R)]_Direction("進行方向",Int)=0
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
           // #pragma multi_compile_fog
            #pragma multi_compile  _DIRECTION_R2L _DIRECTION_L2R

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _monosheet;
            float4 _monosheet_ST;
            float _perFrame;
			int _row;
			int _colum;
			float _th;
            sampler2D _colsheet;
            sampler2D _backsurface;
            float _uvoffset;

            float4 sheetAnimation(sampler2D tex ,float2 uv, int index, float dx, float dy)     
			{
                float uvy = 1-uv.y;
				float2 nuv = float2(uv.x*dx + fmod(index,_row)*dx , 1-(uvy*dy+(ceil(index/_colum))*dy));   //1-(uvy*dy+(ceil(index/_colum))*dy)
				float4 col = tex2D(tex,nuv);
				return col;
			}

            
            float4 reversesheetAnimation(sampler2D tex ,float2 uv, int index, float dx, float dy)
			{
                float uvy = 1-uv.y;
				float2 nuv = float2( (-uv.x/_colum-(1-dx))+fmod(index,_row)*dx , 1-(uvy*dy+(ceil(index/_colum))*dy));
				float4 col = tex2D(tex,nuv);
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
                float2 textuv :TEXCOORD2;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.textuv = TRANSFORM_TEX(v.uv,_monosheet);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {               
                int totalframe = _row*_colum;
                //fmod(経過時間/フレームの間隔,全体のフレーム数) , 経過時間/フレーム間隔で今が何フレーム目かわかる
				float current = fmod(_th/_perFrame,totalframe);
				int index = floor(current);
				float dx = 1.0/_row;
				float dy = 1.0/_colum;


                fixed4 frontsurface = tex2D(_MainTex,i.uv);
                fixed4 backsurface = tex2D(_backsurface, i.uv);
                fixed4 backoriginal = backsurface;
                fixed4 frontoriginal = frontsurface;
                #ifdef _DIRECTION_L2R //_REVERSE_ON
                    _th = -_th+1;
                    current = fmod(_th/_perFrame,totalframe);
                    index = floor(current);
                    fixed4 colAnimation = reversesheetAnimation(_colsheet,i.textuv,index,dx,dy);  
                    fixed4 monoAnimation = reversesheetAnimation(_monosheet,i.textuv,index,dx,dy); 
                    fixed4 col = step((i.uv.x)*0.5+_uvoffset ,_th);     
                     frontsurface *= monoAnimation;
                     frontsurface += colAnimation;  
                                 
                #elif _DIRECTION_R2L         
                    fixed4 colAnimation = sheetAnimation(_colsheet,i.textuv,index,dx,dy);  
                    fixed4 monoAnimation = sheetAnimation(_monosheet,i.textuv,index,dx,dy);
                    fixed4 col = step((1-i.uv.x)*0.5+_uvoffset ,_th);//step(1-i.uv.x+0.02 ,_th); 
                    backsurface *= monoAnimation;
                    backsurface += colAnimation;
                    
                #endif
                
                //fixed4 monoAnimation = sheetAnimation(_monosheet,i.textuv,index,dx,dy);
                //colAnimation = tex2D(_colsheet,float2(i.textuv.x/4-_th,i.textuv.y));
                

                //backsurface *= monoAnimation;
                //backsurface += colAnimation;

                //return backsurface;
                //fixed4 col = step((1-i.uv.x)*0.5+_uvoffset ,_th);//step(1-i.uv.x+0.02 ,_th); 
                //fixed4 col = step((i.uv.x)*0.5+_uvoffset ,_th);
                fixed4 reversecol = 1-col;
                #ifdef _DIRECTION_L2R//_REVERSE_ON
                    col = col*frontsurface;
                    reversecol =  backsurface*reversecol;
                    col += reversecol;
                    if(_th>=1)col= frontoriginal;
                #elif _DIRECTION_R2L
                    col = col*backsurface;
                    reversecol =  frontsurface*reversecol;
                    col += reversecol;
                    if(_th>=1)col= backoriginal;
                #endif

                //if(_th>=1)col= backoriginal; //シェーダー側かスクリプト側のどちらかで裏面の画像へ切り替え 
                
                

                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
