// 平行移動・拡縮・回転 行列サンプル
Shader "Samples/VertexShader-TRSSample"
{
    Properties
    {
        // Transform
        _Position ("Position", Vector) = (0, 0, 0, 0)
        _Rotation ("Rotation", Vector) = (0, 0, 0, 0)   // degreeを期待
        _Scale ("Scale", Vector) = (0, 0, 0, 0)

        // 表示Texture
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata  // Application to Vertex Shader Structure
            {
                float4 vertex : POSITION;       // 頂点座標(モデル空間)
                float2 uv : TEXCOORD0;          // テクスチャUV
            };

            struct v2f  // Vertex Shader to Fragment Shader Structure
            {
                float4 vertex : SV_POSITION;    // 頂点座標(クリップ空間)
                float2 uv : TEXCOORD0;          // テクスチャUV
            };

            // Propertiesに定義した値
            float3 _Position;
            float3 _Rotation;
            float3 _Scale;
            sampler2D _MainTex;
            float4 _MainTex_ST;


            // ------------------------------------------------------------
            // 頂点シェーダー
            v2f vert (appdata v)
            {
                // 以下の例ではMVP(Model-View-Projection)変換前の頂点情報の座標を動かすことで移動/回転/拡縮を行っている。

                // ※注意点
                // UnityはScript(C#)側は列優先となっているが、Shaderの方は行優先となっている。
                // → 例えばコンストラクタで行列を初期化する時の引数の順番は行優先。
                // ただし、計算自体は列ベクトル想定で行う必要がある。(故に「行列 X ベクトル」で掛けている)
                // ▼ 参考 : 空間とプラットフォームの狭間で – Unityの座標変換にまつわるお話 –
                // https://tech.drecom.co.jp/knowhow-about-unity-coordinate-system/

                // ---------------------------
                // スケール
                float4x4 sizeMat = float4x4(
                    float4(_Scale.x, 0, 0, 0),
                    float4(0, _Scale.y, 0, 0),
                    float4(0, 0, _Scale.z, 0),
                    float4(0, 0, 0, 1));
                v.vertex = mul(sizeMat, v.vertex);

                // ---------------------------
                // X軸回転
                // ※回転関連はTransformのInspectorに合わせるために敢えてdegreeからradianに変換している
                float sinX = sin(radians(_Rotation.x));
                float cosX = cos(radians(_Rotation.x));
                float4x4 rotMatX = float4x4(
                    float4(1, 0, 0, 0),
                    float4(0, cosX, -sinX, 0),
                    float4(0, sinX, cosX, 0),
                    float4(0, 0, 0, 1));
                v.vertex = mul(rotMatX, v.vertex);

                // ---------------------------
                // Y軸回転
                float sinY = sin(radians(_Rotation.y));
                float cosY = cos(radians(_Rotation.y));
                float4x4 rotMatY = float4x4(
                    float4(cosY, 0, sinY, 0),
                    float4(0, 1, 0, 0),
                    float4(-sinY, 0, cosY, 0),
                    float4(0, 0, 0, 1));
                v.vertex = mul(rotMatY, v.vertex);

                // ---------------------------
                // Z軸回転
                float sinZ = sin(radians(_Rotation.z));
                float cosZ = cos(radians(_Rotation.z));
                float4x4 rotMatZ = float4x4(
                    float4(cosZ, -sinZ, 0, 0),
                    float4(sinZ, cosZ, 0, 0),
                    float4(0, 0, 1, 0),
                    float4(0, 0, 0, 1));
                v.vertex = mul(rotMatZ, v.vertex);

                // ---------------------------
                // 平行移動
                float4x4 translateMat = float4x4(
                    float4(1, 0, 0, _Position.x),
                    float4(0, 1, 0, _Position.y),
                    float4(0, 0, 1, _Position.z),
                    float4(0, 0, 0, 1));
                v.vertex = mul(translateMat, v.vertex);


                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // MVP変換
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // ------------------------------------------------------------
            // フラグメントシェーダ―
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
