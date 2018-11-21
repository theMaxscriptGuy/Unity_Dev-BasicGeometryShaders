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
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 vertsCirlceA[6];
			float3 vertsCirlceB[6];
			float _RadiusOffset;
			float _Radius;
			float _ZOffset;

			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = v.vertex;//UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}

			void AddVertex(float3 v, float2 uv, inout TriangleStream<g2f> tristream)
			{
				g2f o;
				o.vertex = UnityObjectToClipPos(v);
				o.col = fixed4(o.vertex.xyz,1.0);
				o.uv = uv;
				tristream.Append(o);
			}

			float3x3 lookat(float3 dir,float3 up=float3(0,1,0))
			{
				float3 z=normalize(dir);
				float3 x=normalize(cross(up,z));
				float3 y=normalize(cross(z,x));
				return float3x3(x,y,z);
			}

			[maxvertexcount(102)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream)
			{
				
				//logic to create a circle:
				int numParts = 6;
				float degToRad = 0.0174533;
				float increment = 360.0/(numParts*1.0);
				float rad = _Radius;
				for(int tri = 0; tri < 3; tri++)
				{
					//for every vert create an array of vertices
					float3 origin = input[tri].vertex;
					float3 v;
					for(int i =0; i < numParts;i++)
					{
						//for every increment add a vertex
						float theta = (increment*i)*degToRad;
						v = origin + mul(float3(rad * sin(theta), rad * cos(theta),0.0), lookat(input[tri].normal));
						vertsCirlceA[i] = v;

						v = origin + mul(float3(rad*_RadiusOffset * sin(theta), rad*_RadiusOffset * cos(theta),_ZOffset), lookat(input[tri].normal));
						vertsCirlceB[i] = v;
					}

					//Cap for the circleA
					for(int i = 0; i <= numParts-1; i++)
					{
						if(i == numParts-1)
						{
							AddVertex(origin, input[tri].uv, tristream);
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[0], input[tri].uv, tristream);
						}
						else
						{
							AddVertex(input[tri].vertex, input[tri].uv, tristream);
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[i+1], input[tri].uv, tristream);
						}
						tristream.RestartStrip();
					}
					/*
					//Cap for the circleB
					origin.z += _ZOffset;
					for(int i = 0; i <= numParts-1; i++)
					{
						if(i == numParts-1)
						{
							AddVertex(origin, input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[0], input[tri].uv, tristream);
						}
						else
						{
							AddVertex(origin, input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i+1], input[tri].uv, tristream);
						}
						tristream.RestartStrip();
					}
					*/
					for(int i = 0; i < numParts; i++)
					{
						if(i == numParts-1)
						{
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[0], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i], input[tri].uv, tristream);
						}
						else
						{
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[i+1], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i], input[tri].uv, tristream);
						}
						tristream.RestartStrip();
					}

					for(int i = 0; i < numParts; i++)
					{
						if(i == numParts-1)
						{
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[0], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[0], input[tri].uv, tristream);
						}
						else
						{
							AddVertex(vertsCirlceA[i], input[tri].uv, tristream);
							AddVertex(vertsCirlceA[i+1], input[tri].uv, tristream);
							AddVertex(vertsCirlceB[i+1], input[tri].uv, tristream);
						}
						tristream.RestartStrip();
					}
				}
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
