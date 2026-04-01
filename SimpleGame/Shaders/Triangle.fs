#version 330

layout(location=0) out vec4 FragColor;

// 버텍스 쉐이더와 동일하게 vec4 타입으로 맞춰줍니다.
in vec4 v_Color; 

void main()
{
    FragColor = v_Color;
}