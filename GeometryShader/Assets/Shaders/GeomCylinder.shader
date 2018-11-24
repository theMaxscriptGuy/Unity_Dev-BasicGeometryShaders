// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GeomCylinder"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ZOffset ("Z-Offset", float) = 0.5
		_Radius ("Radius", float) = 0.5
		_RadiusOffset ("Radius-Offset", float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			
			#include "shader.cginc"

			
			ENDCG
		}
		
		Pass {
			Tags {
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM

			#pragma target 3.0

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "shader.cginc"

			float4 MyShadowVertexProgram (g2f v) : SV_POSITION {
				return UnityObjectToClipPos(v.vertex);
			}

			half4 MyShadowFragmentProgram () : SV_TARGET {
				return 0;
			}

			ENDCG
		}
		
	}
}
