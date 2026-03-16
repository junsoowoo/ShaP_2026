#version 330

uniform float u_Time;

in vec3 a_Position;

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
    newPosition.y = a_Position.y +  0.5*sin(t*3.14*2)*0.5;
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
void sin4()
{
    // 1. 별 모양(스피로그래프) 궤적 계산
    // 도형이 별 모양을 빠르게 그리도록 그리는 시간(drawTime)은 빠르게 설정합니다.
    float drawTime = u_Time * 5.0; 
    float cx = cos(drawTime) + 0.5 * cos(drawTime * 1.5);
    float cy = sin(drawTime) - 0.5 * sin(drawTime * 1.5);

    // 기본 별 모양의 좌표
    float px = (cx / 1.5) * 0.9;
    float py = (cy / 1.5) * 0.9;
    
    // 2. 그려지는 전체 궤적(별 모양) 자체를 회전시킬 각도
    // 전체 모양은 천천히 돌도록 회전 시간(rotateTime)은 느리게 설정합니다.
    float rotateTime = u_Time * 0.5; 
    float cosTheta = cos(rotateTime);
    float sinTheta = sin(rotateTime);
    
    // 3. 회전 행렬을 '도형'이 아닌 '궤적 좌표(px, py)'에 적용
    float rotatedPx = px * cosTheta - py * sinTheta;
    float rotatedPy = px * sinTheta + py * cosTheta;
    
    // 4. 도형 크기 축소 (크기 0.1배)
    float localX = a_Position.x * 0.1;
    float localY = a_Position.y * 0.1;

    // 5. 최종 위치 계산: 회전하는 별 모양 궤적 위에 축소된 도형을 올려놓음
    vec4 newPosition;
    newPosition.x = localX + rotatedPx;
    newPosition.y = localY + rotatedPy;
    newPosition.z = a_Position.z;
    newPosition.w = 1.0;

    gl_Position = newPosition;
}

void main()
{
	sin4();
}
