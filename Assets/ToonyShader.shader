Shader "DocktorShaders/ToonyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Thickness("Thickness", Range(0.0, 50.0)) = 0.05
        _OutlineColor("Color", Color) = (1,1,1,1)
        _OutlineThickness("Outline Thickness", Range(0.0, 50.0)) = 0.05
        //_SecondTex("Albedo (RGB)", 2D) = "white" {}
       
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZWrite On
            ZTest LEqual
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Thickness;
            half4 _Color;


            //Vertex Shader
            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.x += sin(v.vertex.y + v.vertex.z + _Time*50) * .5;
                float3 norm = normalize(v.vertex.xyz);
                v.vertex.xyz += norm * _Thickness; 


                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            //
            //Pixel Shader
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }






            //Outline Pass
            Pass
        {

            ZWrite Off
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
            };


            sampler2D _SecondTex;
            float4 _SecondTex_ST;
            half4 _OutlineColor;
            float _OutlineThickness;


            //Vertex Shader
            v2f vert(appdata v)
            {
                v2f o;
                v.vertex.x += sin(v.vertex.y + v.vertex.z + _Time * 50) * .5;
                float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.vertex.xyz));
                v.vertex.xyz += norm * _OutlineThickness;


                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _SecondTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            //
            //Pixel Shader
            fixed4 frag(v2f i) : SV_Target
            {
            return _OutlineColor; // Output outline color
        }
        ENDCG
    }
    }
}
