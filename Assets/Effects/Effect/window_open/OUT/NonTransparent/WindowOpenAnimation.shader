Shader "Unlit/windowOpenAnimation"
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
            int _Direction;

            float4 sheetAnimation(sampler2D tex ,float2 uv, uint index, float dx, float dy,int direction)     
            {
                float uvy = 1-uv.y;//画像反転防止
                float2 R2Luv = float2((uv.x)*dx + fmod(index,_colum)*dx , 1-(uvy*dy+(index/_colum)*dy));
                float2 L2Rnuv = float2((1-uv.x)*dx + fmod(index,_colum)*dx , 1-(uvy*dy+(index/_colum)*dy));
                return tex2D(tex,lerp(R2Luv,L2Rnuv,direction));
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
                float reverse_th = -_th+1;//L2Rを1->0でアニメーションできるように。0->1のほうが都合が良ければ要修正
                //fmod(経過時間/フレームの間隔,全体のフレーム数) , 経過時間/フレーム間隔で今が何フレーム目かわかる
                //lerp(_th,reverse_th,...)でthresholdの向きを制御
                float current = fmod(lerp(_th,reverse_th,_Direction)/_perFrame,_row*_colum);
                uint index = floor(current);//0スタート
                float dx = 1.0/_row;
                float dy = 1.0/_colum;


                fixed4 frontsurface = tex2D(_MainTex,i.uv);
                fixed4 backsurface = tex2D(_backsurface, i.uv);
                float4 surface = lerp(backsurface,frontsurface,_Direction);
                //以下ではsurfaceにR2L側の処理を追加していく
                //途中でL2Rに分岐

                fixed4 colAnimation = sheetAnimation(_colsheet,i.textuv,index,dx,dy,_Direction);  
                fixed4 monoAnimation = sheetAnimation(_monosheet,i.textuv,index,dx,dy,_Direction);
                float4 thR2L = step((1-i.uv.x)*0.5+_uvoffset ,_th);
                float4 thL2R = step((i.uv.x)*0.5+_uvoffset ,reverse_th);
                float4 thMix = lerp(thR2L,thL2R,_Direction);
                surface = surface * monoAnimation + colAnimation;//表面か裏面のテクスチャに対してモノクログラデを乗算して明るい部分と暗い部分を作成。
                surface *= thMix; //stepでしきい値で二値化したものを乗算している。
                float4 reverse_thMix = 1-thMix; //二値化したものを反転させて逆側の画が作れるように
                reverse_thMix = frontsurface*reverse_thMix;
                fixed4 L2R = surface;
                surface +=reverse_thMix;  //これでR2L側は完成。
                reverse_thMix = 1-thMix;  //L2R側のもう半分を作るために再度初期化
                reverse_thMix = backsurface * reverse_thMix;
                L2R+=reverse_thMix;
                
                return lerp(surface,L2R,_Direction);
            }
            ENDCG
        }
    }
}
