#version 330

uniform float u_Time;

in vec3 a_Pos;
out float v_Grey;

float c_PI = 3.141592;

void main()
{
	float value=a_Pos.x + 0.5;

	float newX=a_Pos.x + 0;
	float newY=a_Pos.y + value*0.25*sin((a_Pos.x+0.5) * c_PI * 2 -u_Time);				//시험문제는 이거의 응용 나옴


	vec4 newPosition = vec4(newX,newY, 0, 1.0);
	v_Grey = (1+sin((a_Pos.x+0.5) * c_PI * 2 -u_Time))/2.0;

	gl_Position = newPosition;
}
