// ロゴアニメーションサンプル
Shader "Unlit/Unlit-LogoAnimation"
{
    Properties
    {
        // 表示Texture
        _MainTex ("Texture", 2D) = "white" {}
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
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f  // vert → flag
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Propertiesに定義した値
            sampler2D _MainTex;
            float4 _MainTex_ST;


            // オブジェクトのY方向のスケールを取得
            float ScaleY()
            {   
                /*
                ※以下のフォーラムを参考
                    https://forum.unity.com/threads/can-i-get-the-scale-in-the-transform-of-the-object-i-attach-a-shader-to-if-so-how.418345/

                float3 worldScale = float3(
                    length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x)), // scale x axis
                    length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y)), // scale y axis
                    length(float3(unity_ObjectToWorld[0].z, unity_ObjectToWorld[1].z, unity_ObjectToWorld[2].z))  // scale z axis
                    );
                */
                // Y方向のみ取得
                return length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y));
            }

            // ------------------------------------------------------------
            // 頂点シェーダー
            v2f vert(appdata v)
            {
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

                // 原点を下端に設定する為にオフセットをずらしてから回転させる。
                // → Yスケール半分のオフセットを上にずらしてから回転をかけ、元の位置に戻す。
                float halfScaleY = ScaleY() / 2;
                v.vertex.y += halfScaleY;
                v.vertex.yz = mul(rotationMatrix, v.vertex.yz);
                v.vertex.y -= halfScaleY;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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
