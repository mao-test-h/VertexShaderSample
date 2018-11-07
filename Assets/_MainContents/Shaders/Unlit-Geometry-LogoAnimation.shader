// ロゴアニメーションサンプル(ジオメトリシェーダ―を用いて形状関係なしに強制的にロゴに塗り替える)
Shader "Samples/Unlit-Geometry-LogoAnimation"
{
    Properties
    {
        // 表示Texture
        _MainTex ("Texture", 2D) = "white" {}

        // オブジェクトのスケール
        // ※こちらはunity_ObjectToWorldから取得せずにPropertiesから設定
        _Scale ("Scale", Vector) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Cull Off
        Lighting Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                uint vid : SV_VertexID;
            };
            
            struct v2g  // vert → geom
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;  // float4(uv.x, uv.y, SV_VertexID, 0)
            };

            struct g2f  // geom → frag
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Propertiesに定義した値
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Scale;


            // ------------------------------------------------------------
            // 頂点シェーダー
            v2g vert(appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                // geom側にSV_VertexIDを渡せないので代わりに使っていないuv.zに入れておく
                o.uv.z = v.vid;
                return o;
            }

            // ------------------------------------------------------------
            // ジオメトリシェーダー
            // ※引数には1頂点のみを受け取る
            //      → 中で4頂点に増やすことで板ポリにしてTextureを貼るイメージ
            [maxvertexcount(4)]
            void geom(point v2g input[1], inout TriangleStream<g2f> outStream)
            {
                // 1頂点分のみロゴを生成(ここで塞き止めないと頂点分だけロゴが生まれる)
                uint vid = input[0].uv.z;
                if(vid != 0) return;

                // ロゴデータ(頂点、UV)
                float4 Vertices[4] = { float4(-2.4, 0.6, 0.0, 0.0), float4(2.4, 0.6, 0.0, 0.0), float4(-2.4, -0.6, 0.0, 0.0), float4(2.4, -0.6, 0.0, 0.0), };
                float2 UVs[4] = { float2(0.0, 1.0), float2(1.0, 1.0), float2(0.0, 0.0), float2(1.0, 0.0), };

                // コマ落ちアニメーション(radians)
                float Animation[16] = 
                {
                    1.5707963267948966,
                    1.4660765716752369,
                    1.3613568165555772,
                    1.2566370614359172,
                    1.1519173063162575,
                    1.0471975511965979,
                    0.9424777960769379,
                    0.8377580409572781,
                    0.7330382858376184,
                    0.6283185307179586,
                    0.5235987755982989,
                    0.4188790204786392,
                    0.31415926535897926,
                    0.2094395102393195,
                    0.10471975511965975,
                    0,
                };

                // sinで取得できる-1~1の値を0~1の範囲に正規化
                float normal = (_SinTime.w + 1) / 2;
                // SinTimeの値を0~15の範囲にスケール。
                // 値を量子化することでアニメーションテーブルのIndexとして扱う。
                float rot = Animation[round(normal*15)];

                // 回転行列
                float sinX = sin(rot);
                float cosX = cos(rot);
                float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);

                // 頂点の生成
                for(int i = 0; i < 4; ++i)
                {
                    g2f o;
                    // 原点を下端に設定する為にオフセットをずらしてから回転させる。
                    // → Yスケール半分のオフセットを上にずらしてから回転をかけ、元の位置に戻す。
                    float halfScaleY = _Scale.y / 2;
                    o.vertex = Vertices[i];
                    o.vertex.y += halfScaleY;
                    o.vertex.yz = mul(rotationMatrix, o.vertex.yz);
                    o.vertex.y -= halfScaleY;

                    o.vertex = UnityObjectToClipPos(o.vertex);
                    o.uv = UVs[i];
                    o.uv = TRANSFORM_TEX(o.uv, _MainTex);
                    outStream.Append(o);
                }
                outStream.RestartStrip();
            }

            // ------------------------------------------------------------
            // フラグメントシェーダ―
            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
