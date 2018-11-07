Shader "Unlit/Wiggle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Amount ("Wave1 Frequency", float) = 1
        _TimeScale ("Wave1 Speed", float) = 1.0
        _Distance ("Distance", float) = 0.1
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TimeScale;
            float _Amount;
            float _Distance;

            v2f vert (appdata v)
            {
                // うねうね
                // 参考 : https://github.com/Unity-Technologies/EntityComponentSystemSamples/blob/master/Samples/Assets/SampleAssets/Shaders/Wiggle.shader
                float4 offs = sin(_Time.y * _TimeScale + v.vertex.z * _Amount) * _Distance;
                v.vertex.x += offs;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
