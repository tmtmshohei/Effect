Shader "Unlit/Simple_ClearSphere"
{
	Properties
	{
		
		[HDR] _RimColor("Rim Color", Color) = (0.5,0.5,0.5,0.5)
    	_RimPower("Rim Power", Range(0.01,10.0)) = 1.0
		_texture("texture" , 2D) = "white"{}
	}

 Category
 {
	Tags 
	{ 
  		//Queue = 描画の優先度　TransparentはBackgroundやGeometryなどの不透明オブジェクトを全て描画してから今回の半透明オブエジェクトが描画されます。
		"Queue" = "Transparent"      		
		"IgnoreProjector" = "True"
    	"RenderType" = "Transparent"
  		"PreviewType" = "Sphere" 
		"Distort" = "UVMesh"
    }

	Blend SrcAlpha One
    ColorMask RGB
    Cull Off 
    Lighting Off 
    ZWrite Off

	SubShader
	{

		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			fixed4 _RimColor;
			fixed  _RimPower;
			sampler2D _texture;
			float4 _texture_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
				float2 uv :TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float2 uv :TEXCOORD0;
				float3 viewDir :TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : NORMAL;
				UNITY_FOG_COORDS(3)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
          		o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _texture);
          		o.worldPos = mul(unity_ObjectToWorld, v.vertex);
          		o.worldNormal = UnityObjectToWorldNormal(v.normal);
          		o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);//mul(unity_ObjectToWorld, v.vertex).xyz);
          		UNITY_TRANSFER_FOG(o,o.vertex);
          		return o;;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//ここの内積が0に近いと法線と視線ベクトルが垂直に近く、1に近いと平行に近い
				float ndotv_org = dot(i.worldNormal, normalize(i.viewDir));
          		float ndotv = 1 - abs(ndotv_org);
				//正規化しているがndotvのまま使っても大丈夫
				float rim = saturate(ndotv);
				//アルファ値　透明度を作っている
          		rim = pow(rim, _RimPower);
				i.uv.y+=-_Time.y;
				float4 tex = tex2D(_texture,i.uv);
				fixed4 col = _RimColor*rim;
				col *= tex;
								
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0, 0, 0, 0));
				return (col);

			}
			ENDCG
		}
	}
  }
}