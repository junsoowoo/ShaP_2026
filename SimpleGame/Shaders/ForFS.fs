#version 330

in vec2 v_Tex;
uniform float u_Time;
uniform vec4 u_Points[500];

layout(location=0) out vec4 FragColor;

const float c_PI= 3.1415926;
const vec4 c_Points[2] = vec4[2](
    vec4(0.5, 0.5, 0.0, 0.5), 
    vec4(0.7, 0.7, 0.5, 1.0)
);

void Simple()
{
	if(v_Tex.x < 0.5) 
   FragColor = vec4(0);
   else 
   FragColor = vec4(1);
}
void Line()
{
	float trans = c_PI*0.5;									//패턴 이동
	float periodX = (v_Tex.x * 2 * c_PI -trans) *5;
	float periodY = (v_Tex.y * 2 * c_PI- trans) *5;			//주기 계산
	float valueX= pow(abs(sin(periodX)),16);
	float valueY= pow(abs(sin(periodY)),16);				//라인 조정, 사선으로 만들기 연습(periodX+periodY)
	FragColor=vec4(max(valueX,valueY));						//패턴 그리기

	//FragColor = vec4(v_Tex.xy,0,1);
}
void Circle()
{
	vec2 center = vec2(0.5,0.5);
	vec2 currPos = v_Tex;
	float dist = distance(center, currPos);
	float width = 0.01;
	float radius = 0.5;

	if(dist >radius-width&& dist<radius)
	{
		FragColor = vec4(1);
	}
	else
	{
		FragColor = vec4(0);
	}
}
//동심원 그리기
void Circles()
{
	vec2 center =vec2(0.5,0.5);
	vec2 currPos = v_Tex;
	float count = 5;
	
	float dist = distance(center, currPos);
	
	float grey=pow(abs(sin(dist * 4* c_PI*count + u_Time*10)),4);

	FragColor = vec4(grey);
}

void RainDrop()
{
	float accum=0;
	for(int i=0;i<500;i++)
	{
		float sTime=u_Points[i].z;
		float lTime=u_Points[i].w;
		float newTime=u_Time-sTime;
		if(newTime>0)
		{
			float t=fract(newTime/lTime);												//0~1						
			float oneMinus=1-t;															//1~0
			t=t*lTime;																	//0~1

			vec2 center =u_Points[i].xy;
			vec2 currPos = v_Tex;
			float count = 5;
			float range = t/5;

			float dist = distance(center, currPos);
			float fade = clamp(range - dist, 0, 1)*(1/range);							//중심에서 멀어질수록 사라지는 효과
			float grey=pow(
				abs(sin(dist * 4* c_PI*count - t*10)),4);
			accum+=grey*fade*oneMinus;
		}
	}
	FragColor = vec4(accum);
}
void main()
{
   RainDrop();
}