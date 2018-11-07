Shader "Unlit/Samdbox"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Position ("Position", Vector) = (0, 0, 0, 0)
        _Rotation ("Rotation", Vector) = (0, 0, 0, 0)   // degreeを期待
        _Scale ("Scale", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata  // Application to Vertex Shader Structure
            {
                float4 vertex : POSITION;   // 頂点座標(モデル空間)
                float2 uv : TEXCOORD0;      // テクスチャUV
                uint vid : SV_VertexID;     // ランタイムによって自動的に生成される頂点単位の識別子
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            #define PI 3.1415926535

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Position;
            float3 _Rotation;
            float3 _Scale;

            // 頂点シェーダー(モデル変換行列を直接書き換える例)
            v2f vert (appdata v)
            {
                // モデル変換行列を取得(unity_ObjectToWorldはUnityで参照できる行列)
                float4x4 object2World = unity_ObjectToWorld;

                // スケール
                // ※これで調整できなくはないが、
                //   直接代入すると他の変換(回転)とぶつかるのでおかしくなったり。
                //object2World._11_22_33 = _Scale;

                // X軸に回転
                // ※float4x4を使わなくてもスウィズル演算子を用いてこう書くことも出来る
                float sinX = sin(radians(_Rotation.x));
                float cosX = cos(radians(_Rotation.x));
                float2x2 rotMatX = float2x2(
                                        cosX, -sinX,
                                        sinX, cosX);
                v.vertex.yz = mul(rotMatX, v.vertex.yz);

                // 平行移動
                // ※平行移動は他の変換の影響を受けないので直接代入でも行ける
                // → 但し、Transform.positionの値は反映されなくなる上にカメラ外に動かすとカリングされる。
                object2World._14_24_34 = _Position;

                // モデル変換
                v.vertex = mul(object2World, v.vertex);

                v2f o;
                o.vertex = mul(UNITY_MATRIX_VP, v.vertex);      // VP変換
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // 頂点シェーダー(90度回転させる例)
            /*
            v2f vert (appdata v)
            {
                // X軸回転
                float sinX = sin(PI/2);
                float cosX = cos(PI/2);
                float4x4 rotMatX = float4x4(
                    float4(1, 0, 0, 0),
                    float4(0, cosX, -sinX, 0),
                    float4(0, sinX, cosX, 0),
                    float4(0, 0, 0, 1));
                v.vertex = mul(rotMatX, v.vertex);

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // MVP変換
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            */

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
