#version 330

uniform float u_Time;

in vec3 a_Position;
in float a_Mass;
in vec2 a_Vel;
in vec2 a_Offset;
in float a_RV; 
in float a_RV1;

const float c_PI = 3.1415926535897932384626433832795;
const vec2 c_G= vec2(0.0, -9.8);

void Basic()
{
float t = mod(u_Time *10 ,1.0);
	vec4 newPosition;
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y;
	newPosition.z = a_Position.z;
	gl_Position = newPosition;
}
void sin1()
{
	float t = mod(u_Time *10 ,1.0);
	vec4 newPosition;
	newPosition.x = a_Position.x + t;
	newPosition.y = a_Position.y + 0.5*sin(t*3.14*2)*0.5;
	newPosition.z = a_Position.z;
	gl_Position = newPosition;
}
void sin2()
{
	float t = mod(u_Time *10 ,1.0);
	vec4 newPosition;
	newPosition.x = a_Position.x  - 1.0 + t * 2;
    newPosition.y = a_Position.y +  0.5*sin(t*3.14*2)*0.5;      //시험은 이런 곳에 빈 칸이나 함수 전체 쓰기 이런 거 나옴
    newPosition.z = a_Position.z;
    newPosition.w = 1.0;

	gl_Position = newPosition;
}
void sin3()
{
	float t = mod(u_Time *10 ,1.0);
	vec4 newPosition;
	newPosition.x = a_Position.x  - 1.0 + t * 2;
	newPosition.y = a_Position.y +  0.5*sin(t*3.14*2*2)*0.5;
	newPosition.z = a_Position.z;
	newPosition.w = 1.0;
	gl_Position = newPosition;
}
void circle1()
{
	float t = mod(u_Time *10 ,1.0);
	float r = 0.5;
	vec4 newPosition;
	newPosition.x = a_Position.x + 1.0*sin(t*3.14*2);
	newPosition.y = a_Position.y + 1.0*cos(t*3.14*2);
	newPosition.z = a_Position.z;
	newPosition.w = 1.0;
	gl_Position = newPosition;
}
float pseudoRandom (float n) 
{
    return fract(sin(n) * 43758.5453);
}
void Falling()
{
    float newTime = u_Time - pseudoRandom(a_RV1);

    vec4 newPos;

    if(newTime > 0.0)
    {
        // 반복 생성
        float t = mod(newTime, 3.0);
        float tt = t * t;

        // 꼬리 밀도 (위쪽 빽빽)
        float tail = pow(a_RV, 2.0) * 0.8;

        // 상단 고정 위치
        float rootY = 0.9;

        // 꼬리 곡선
        float curve = sin(tail * 3.0) * 0.15;

        // 전체 꼬리 살랑 (계속 흔들림)
        float sway = sin(u_Time * 1.5 + tail * 4.0) * 0.08;

        // 끝쪽 더 많이 흔들림
        float tip = sin(u_Time * 2.0 + a_RV * 6.28) * 0.05 * a_RV;

        newPos.x = a_Position.x + curve + sway + tip;
        newPos.y = rootY - tail + 0.5 * c_G.y * tt * 0.15;
        newPos.z = a_Position.z;
        newPos.w = 1.0;
    }
    else
    {
        newPos = vec4(-1000,-1000,0,1);
    }

    gl_Position = newPos;
}

void main()
{
	Falling();
}