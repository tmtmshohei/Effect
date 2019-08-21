Shader "Unlit/Surfacemove_ClearSphere"
{
	Properties
	{
		_MainTex("Main Tex (Triplanar)", 2D) = "white" {}
    	_MainTexScale("Main Tex Scale", Float) = 0.0
    	_MainTexScroll ("Main Tex Scroll", Float) = 0.0
    	_MainTexStep("Main Tex Step", Range(2, 64)) = 4

    	[HDR] _NoiseColor1("Noise Color 1", Color) = (0.5,0.5,0.5,0.5)
    	[HDR] _NoiseColor2("Noise Color 2", Color) = (0.5,0.5,0.5,0.5)

    	[HDR] _IntersectColor("Intersect Color", Color) = (0.5,0.5,0.5,0.5)
    	_IntersectPower("Intersect Power", Range(0.1,10.0)) = 1.0
    	_IntersectStep("Intersect Step", Range(2, 64)) = 4

    	[HDR] _RimColor("Rim Color", Color) = (0.5,0.5,0.5,0.5)
    	_RimPower("Rim Power", Range(0.01,10.0)) = 1.0
    	_RimStep("Rim Step", Range(2, 64)) = 4

    	_FadeStrength("Fade Strength", Range(-2.0, 2.0)) = 0.0
	}


	SubShader
	{
		Tags 
		{ 
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Sphere"
		}

		Pass
		{
			Name "BASE"
			Tags {"LightMode" = "Always"}

			Blend SrcAlpha One 
			ColorMask RGB 
			Cull Off 
			Lighting Off 
			ZWrite Off 

			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed _MainTexScale;
			fixed _MainTexScroll;
			fixed _MainTexStep;

			fixed4 _NoiseColor1;
			fixed4 _NoiseColor2;

			fixed4 _IntersectColor;
			fixed _IntersectPower;
			fixed _IntersectStep;

			fixed4 _RimColor;
			fixed _RimPower;
			fixed _RimStep;

			fixed _FadeStrength;


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				//float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				//float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 projPos : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : NORMAL;
				UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
			};


			
			v2f vert (appdata v)
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
          		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.projPos = ComputeGrabScreenPos(o.vertex);

				COMPUTE_EYEDEPTH(o.projPos.z);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			
			fixed4 frag (v2f i) : SV_Target
			{
				half time = (_Time.x * _MainTexScroll);
				
				half2 yUV = i.worldPos.xz / _MainTexScale;
				half2 xUV = i.worldPos.yz / _MainTexScale;
				half2 zUV = i.worldPos.xy / _MainTexScale;

				half4 yDiff = tex2D(_MainTex,yUV+time);
				half4 xDiff = tex2D(_MainTex,xUV+time);
				half4 zDiff = tex2D(_MainTex,zUV+time);

				half3 blendWeights = abs(i.worldNormal);
          		blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

				half4 mt = (xDiff*blendWeights.x)+(yDiff*blendWeights.y)+(zDiff*blendWeights.z);

				float ndotv_org = dot(i.worldNormal,normalize(i.viewDir));
				float ndotv = 1 - abs(ndotv_org);

				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.projPos)));
				float intersect = pow(saturate( 1-(sceneZ - i.projPos.z)),_IntersectPower);
				intersect = floor(intersect * _IntersectStep) / _IntersectStep;

				float rim = saturate(ndotv);
				rim = pow(rim,_RimPower);
				rim = floor(rim*_RimStep) / _RimStep;

				float ns = 0;

				fixed4 col = lerp(_NoiseColor1,_NoiseColor2,ns)*(1-rim)*(1-intersect);
				col.rgb *= saturate(floor(mt.rgb*_MainTexStep)/_MainTexStep);

				ndotv = 1 -max(0,ndotv_org);
				col = col + (_RimColor*rim);
				col = col * max(ndotv - _FadeStrength,0);
				col = col + (_IntersectColor * intersect);


				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
