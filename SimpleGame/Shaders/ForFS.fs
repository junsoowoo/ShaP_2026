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
void Flag()
{
	float amp = 0.5;
	float speed =10;
	float sinInput=v_Tex.x * c_PI * 2  - u_Time*speed;
    float sinValue = v_Tex.x*amp *(((sin(sinInput) +1)/2)-0.5)+0.5;		//v_Tex.x * 는 왼쪽 고정
	
	float fWidth=0.5;													//끝을 뽀족하게 말고
	float width=0.5 *mix(1,fWidth,v_Tex.x);								//1-v_Tex.x 는 점점 뽀족하게
    float grey=0;

   if(v_Tex.y < sinValue + width/2 && v_Tex.y > sinValue -width/2)
   {
	   grey=1;
   }
   else
   {
	   grey =0;
   }
   FragColor = vec4(grey);
}

void Flame()
{
	float amp = 0.5;
	float speed =10;
	float newY= 1-v_Tex.y;
	float sinInput=newY * c_PI * 2  - u_Time*speed;
    float sinValue = newY*amp *(((sin(sinInput) +1)/2)-0.5)+0.5;		//v_Tex.x * 는 왼쪽 고정
	
	float fWidth=0.;													//끝을 뽀족하게 말고
	float width=0.5 *mix(fWidth,1,newY);								//1-v_Tex.x 는 점점 뽀족하게
    float grey=0;

   if(v_Tex.x < sinValue + width/2 && v_Tex.x > sinValue -width/2)
   {
	   grey=1;
   }
   else
   {
	   grey =0;
   }
   FragColor = vec4(grey);
}
void main()
{
	Flame();
}