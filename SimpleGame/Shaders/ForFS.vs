#version 330

uniform float u_Time;
layout(location = 0) in vec3 a_Pos;
layout(location = 1) in vec2 a_Tex;

out vec2 v_Tex;

void main()
{
	vec4 newPosition;
	newPosition =vec4(a_Pos, 1.0);
	v_Tex = a_Tex;
	gl_Position = newPosition;
}
