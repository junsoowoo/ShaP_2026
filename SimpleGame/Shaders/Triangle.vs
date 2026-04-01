#version 330

uniform float u_Time;

in vec3 a_Position;
in float a_Mass;
in vec2 a_Vel;
in vec2 a_Offset;
in float a_RV; 
in float a_RV1;
in float a_RV2;         

out vec4 v_Color;

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

void Thrust()
{
    float newTime = u_Time - a_RV1;
    
    if(newTime > 0)
    {
        float amp = 2*(a_RV -0.5);
        float period = a_RV2;
	    float t = mod(newTime ,1.0);
        float ampScale = 0.5 *t;         //0.5 ~ 1
        float sizeScale = 2 * t;         //0 ~ 2

        vec4 newPosition;
	    newPosition.x = a_Position.x* sizeScale - 1.0 + t * 2.0 ;                                   //왼쪽에서부터 시작하면 -1, 시간 두 배해서 끝까지
        newPosition.y = a_Position.y* sizeScale +  amp  * sin(t*2*c_PI*period) * ampScale ;          //시험은 이런 곳에 빈 칸이나 함수 전체 쓰기 이런 거 나옴
        newPosition.z = a_Position.z;
        newPosition.w = 1.0;

	    gl_Position = newPosition;
        v_Grey= 1-t;
    }
    else
    {
        gl_Position = vec4(10000);
        v_Grey= 1-t;
    }
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
    float newTime = u_Time - pseudoRandom(a_RV1) *3;
    if(newTime > 0.0)
    {
        float lifeTime = a_RV2*0.2 + 0.5;                               //랜덤밸류 추가했는데 라이프타임에 랜덤밸류를 넣어라(빈칸)
        vec4 newPos;
        float t = mod(newTime, lifeTime);
        float scale = pseudoRandom(a_RV1) * (lifeTime-t)/lifeTime;      //이런 수식 만들기
        float tt = t * t;
        float vx = a_Vel.x;
        float vy = a_Vel.y;
        float initPosX = a_Position.x * scale + sin(a_RV * 2.0 * c_PI);
        float initPosY = a_Position.y * scale + cos(a_RV * 2.0 * c_PI);

        newPos.x = initPosX + vx * t;
        newPos.y = initPosY + vy * t + 0.5 * c_G.y * tt;
        newPos.z = a_Position.z;
        newPos.w = 1.0;

        gl_Position = newPos;
    }
    else
    {
        gl_Position=vec4(-10000,1000,0,1);
    }
}
void Fire()
{
    // 파티클들이 한 번에 나타나지 않도록 랜덤 시간 부여
    float newTime = u_Time - pseudoRandom(a_RV1) * 3.0;
    
    if(newTime > 0.0)
    {
        // 수명: 0.5 ~ 1.0초 사이로 설정
        float lifeTime = a_RV2 * 0.5 + 0.5;
        float rawT = mod(newTime, lifeTime);
        
        // t는 0.0(시작)에서 1.0(끝)까지 변하는 정규화된 시간입니다.
        float t = rawT / lifeTime; 

        // 파티클 크기: 위로 올라갈수록 작아지게 (1.0 -> 0.0)
        float sizeScale = 1.0 - t; 

        // 흔들림: 불꽃이 위로 가면서 좌우로 살짝 일렁이는 효과
        float sway = sin(t * 10.0 + a_RV1 * 20.0) * 0.1 * t;
        
        // 초기 퍼짐: 중심(0)을 기준으로 좌우로 약간 퍼지게
        float spreadX = (a_RV - 0.5) * 0.2; 
        
        // 상승 속도: 각 파티클마다 약간씩 다른 속도로 솟구침
        float vy = 2.0 + a_RV2 * 1.5; 

        vec4 newPosition;
        // 크기를 적용하고, X축은 일렁임 추가, Y축은 (0, -1)에서 시작하여 위로 상승
        newPosition.x = a_Position.x * sizeScale + spreadX + sway;
        newPosition.y = a_Position.y * sizeScale - 1.0 + vy * rawT; 
        newPosition.z = a_Position.z;
        newPosition.w = 1.0;

        gl_Position = newPosition;

        // 터보라이터 색상 그라데이션 (mix 함수 사용)
        vec4 blue   = vec4(0.1, 0.4, 1.0, 1.0); // 하단: 파란색
        vec4 red    = vec4(1.0, 0.1, 0.0, 1.0); // 중하단: 빨간색
        vec4 orange = vec4(1.0, 0.5, 0.0, 1.0); // 중상단: 주황색
        vec4 yellow = vec4(1.0, 1.0, 0.0, 1.0); // 상단: 노란색

        if(t < 0.2) {
            // 시간의 0~20% 구간: 파랑 -> 빨강
            v_Color = mix(blue, red, t / 0.2);
        } else if(t < 0.6) {
            // 시간의 20~60% 구간: 빨강 -> 주황
            v_Color = mix(red, orange, (t - 0.2) / 0.4);
        } else {
            // 시간의 60~100% 구간: 주황 -> 노랑
            v_Color = mix(orange, yellow, (t - 0.6) / 0.4);
        }
        
        // (옵션) 위로 갈수록 불꽃이 서서히 투명해지며 사라지게 만듭니다.
        // C++ 환경에서 알파 블렌딩(GL_BLEND)이 켜져 있어야 제대로 보입니다.
        v_Color.a = 1.0 - t; 
    }
    else
    {
        gl_Position = vec4(-10000.0, 10000.0, 0.0, 1.0);
        v_Color = vec4(0.0);
    }
}
void main()
{
	Fire();
}