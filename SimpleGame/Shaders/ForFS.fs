#version 330

in vec2 v_Tex;
uniform float u_Time;

layout(location=0) out vec4 FragColor;

void Simple()
{
	if(v_Tex.x < 0.5) 
   FragColor = vec4(0);
   else 
   FragColor = vec4(1);
}
const float c_PI= 3.1415926;
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
	
	float grey=pow(abs(sin(dist * 4* c_PI*count + u_Time*5)),32);

	FragColor = vec4(grey);
}
void main()
{
   Circles();
   
}