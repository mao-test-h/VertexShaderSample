// SpriteRenderer向け ロゴアニメーションサンプル

// ▽ Reference
// - Unity2018.3.b8 builtin_shaders Sprite/Default
//      - Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
Shader "Samples/Sprites/Sprite-Default-LogoAnimation"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment SpriteFrag
            #pragma target 2.0

            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

            #include "UnitySprites.cginc"

            v2f vert(appdata_t v)
            {
                // =================================

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

                // 「_SinTime : -1~1」の値を0~1の範囲に正規化
                float normal = (_SinTime.w + 1) / 2;
                // SinTimeの値を0~15の範囲にスケール。値を量子化することでアニメーションテーブルのIndexとして扱う。
                float rot = Animation[round(normal*15)];

                // 回転行列
                float sinX = sin(rot);
                float cosX = cos(rot);
                float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);

                // 回転の適用。TextureSettingsに於けるPivotは「Bottom」を期待
                v.vertex.yz = mul(rotationMatrix, v.vertex.yz);

                // =================================

                v2f o;
                UNITY_SETUP_INSTANCE_ID (v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityFlipSprite(v.vertex, _Flip);
                o.vertex = UnityObjectToClipPos(o.vertex);
                o.texcoord = v.texcoord;
                o.color = v.color * _Color * _RendererColor;

                #ifdef PIXELSNAP_ON
                o.vertex = UnityPixelSnap (o.vertex);
                #endif

                return o;
            }
        ENDCG
        }
    }
}
