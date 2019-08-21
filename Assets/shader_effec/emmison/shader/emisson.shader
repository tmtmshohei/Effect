// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/emisson" {
	Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _EmissionTex ("Emission (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Brightness ("Brightness", Float) = 0.0
        _BrightnessOffset ("Brightness Offset", Float) = -1.0
        _BrightnessModifier ("Brightness Modifier", Float) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex; 
        sampler2D _EmissionTex; // 発光用のテクスチャ

        struct Input {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _EmissionColor; // 発光の色
        half _Brightness; // 発光の値 (これをAnimationClipから操作させます)
        half _BrightnessOffset; // 発光値の基準値
        half _BrightnessModifier; // 発光値の係数

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 e = tex2D (_EmissionTex, IN.uv_MainTex);
            o.Albedo = c;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Emission = max(0.0, e * _Brightness * _BrightnessModifier + _BrightnessOffset) * _EmissionColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
