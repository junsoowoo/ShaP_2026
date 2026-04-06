#include "stdafx.h"
#include "Renderer.h"
#include <vector>
#include "Dependencies\freeglut.h"

Renderer::Renderer(int windowSizeX, int windowSizeY)
{
	Initialize(windowSizeX, windowSizeY);
}


Renderer::~Renderer()
{
}

void Renderer::Initialize(int windowSizeX, int windowSizeY)
{
	//Set window size
	m_WindowSizeX = windowSizeX;
	m_WindowSizeY = windowSizeY;

	//Load shaders
	m_SolidRectShader = CompileShaders("./Shaders/SolidRect.vs", "./Shaders/SolidRect.fs");

	m_TriangleShader = CompileShaders("./Shaders/Triangle.vs", "./Shaders/Triangle.fs");

	m_FSShader = CompileShaders("./Shaders/ForFS.vs", "./Shaders/ForFS.fs");

	//Create VBOs
	CreateVertexBufferObjects();

	int index = 0;
	for(int i =0; i < 500; i++)
	{
		float x = (float)rand() / RAND_MAX ;
		float y = (float)rand() / RAND_MAX;
		float sTime = (float)rand() / RAND_MAX * 5.0f;
		float lTime = (float)rand() / RAND_MAX * 0.5f;

		m_RainInfo[index++] = x;
		m_RainInfo[index++] = y;
		m_RainInfo[index++] = sTime;
		m_RainInfo[index++] = lTime;
	}
	if (m_SolidRectShader > 0 && m_VBORect > 0 && m_FSShader)
	{
		m_Initialized = true;
	}

}

bool Renderer::IsInitialized()
{
	return m_Initialized;
}

void Renderer::CreateVertexBufferObjects()
{
	float rect[]
		=
	{
		-1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f, -1.f / m_WindowSizeX, 1.f / m_WindowSizeY, 0.f, 1.f / m_WindowSizeX, 1.f / m_WindowSizeY, 0.f, //Triangle1
		-1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f,  1.f / m_WindowSizeX, 1.f / m_WindowSizeY, 0.f, 1.f / m_WindowSizeX, -1.f / m_WindowSizeY, 0.f, //Triangle2
	};

	glGenBuffers(1, &m_VBORect);
	glBindBuffer(GL_ARRAY_BUFFER, m_VBORect);
	glBufferData(GL_ARRAY_BUFFER, sizeof(rect), rect, GL_STATIC_DRAW);

	float fs[] =
	{
		-1, -1, 0, 0, 1,
		1, 1,0,1,0,
		-1, 1,0,0,0,		//triangle1
		-1,-1,0,0,1,
		1,-1,0,1,1,
		1,1,0,1,0		//triangle2
	};

	glGenBuffers(1, &m_FSVBO);
	glBindBuffer(GL_ARRAY_BUFFER, m_FSVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(fs), fs, GL_STATIC_DRAW);

	GenParticles(10000);
}

void Renderer::AddShader(GLuint ShaderProgram, const char* pShaderText, GLenum ShaderType)
{
	//쉐이더 오브젝트 생성
	GLuint ShaderObj = glCreateShader(ShaderType);

	if (ShaderObj == 0) {
		fprintf(stderr, "Error creating shader type %d\n", ShaderType);
	}

	const GLchar* p[1];
	p[0] = pShaderText;
	GLint Lengths[1];
	Lengths[0] = strlen(pShaderText);
	//쉐이더 코드를 쉐이더 오브젝트에 할당
	glShaderSource(ShaderObj, 1, p, Lengths);

	//할당된 쉐이더 코드를 컴파일
	glCompileShader(ShaderObj);

	GLint success;
	// ShaderObj 가 성공적으로 컴파일 되었는지 확인
	glGetShaderiv(ShaderObj, GL_COMPILE_STATUS, &success);
	if (!success) {
		GLchar InfoLog[1024];

		//OpenGL 의 shader log 데이터를 가져옴
		glGetShaderInfoLog(ShaderObj, 1024, NULL, InfoLog);
		fprintf(stderr, "Error compiling shader type %d: '%s'\n", ShaderType, InfoLog);
		printf("%s \n", pShaderText);
	}

	// ShaderProgram 에 attach!!
	glAttachShader(ShaderProgram, ShaderObj);
}

bool Renderer::ReadFile(char* filename, std::string* target)
{
	std::ifstream file(filename);
	if (file.fail())
	{
		std::cout << filename << " file loading failed.. \n";
		file.close();
		return false;
	}
	std::string line;
	while (getline(file, line)) {
		target->append(line.c_str());
		target->append("\n");
	}
	return true;
}

GLuint Renderer::CompileShaders(char* filenameVS, char* filenameFS)
{
	GLuint ShaderProgram = glCreateProgram(); //빈 쉐이더 프로그램 생성

	if (ShaderProgram == 0) { //쉐이더 프로그램이 만들어졌는지 확인
		fprintf(stderr, "Error creating shader program\n");
	}

	std::string vs, fs;

	//shader.vs 가 vs 안으로 로딩됨
	if (!ReadFile(filenameVS, &vs)) {
		printf("Error compiling vertex shader\n");
		return -1;
	};

	//shader.fs 가 fs 안으로 로딩됨
	if (!ReadFile(filenameFS, &fs)) {
		printf("Error compiling fragment shader\n");
		return -1;
	};

	// ShaderProgram 에 vs.c_str() 버텍스 쉐이더를 컴파일한 결과를 attach함
	AddShader(ShaderProgram, vs.c_str(), GL_VERTEX_SHADER);

	// ShaderProgram 에 fs.c_str() 프레그먼트 쉐이더를 컴파일한 결과를 attach함
	AddShader(ShaderProgram, fs.c_str(), GL_FRAGMENT_SHADER);

	GLint Success = 0;
	GLchar ErrorLog[1024] = { 0 };

	//Attach 완료된 shaderProgram 을 링킹함
	glLinkProgram(ShaderProgram);

	//링크가 성공했는지 확인
	glGetProgramiv(ShaderProgram, GL_LINK_STATUS, &Success);

	if (Success == 0) {
		// shader program 로그를 받아옴
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		std::cout << filenameVS << ", " << filenameFS << " Error linking shader program\n" << ErrorLog;
		return -1;
	}

	glValidateProgram(ShaderProgram);
	glGetProgramiv(ShaderProgram, GL_VALIDATE_STATUS, &Success);
	if (!Success) {
		glGetProgramInfoLog(ShaderProgram, sizeof(ErrorLog), NULL, ErrorLog);
		std::cout << filenameVS << ", " << filenameFS << " Error validating shader program\n" << ErrorLog;
		return -1;
	}

	glUseProgram(ShaderProgram);
	std::cout << filenameVS << ", " << filenameFS << " Shader compiling is done.";

	return ShaderProgram;
}

void Renderer::DrawSolidRect(float x, float y, float z, float size, float r, float g, float b, float a)
{
	float newX, newY;

	GetGLPosition(x, y, &newX, &newY);

	//Program select
	glUseProgram(m_SolidRectShader);

	glUniform4f(glGetUniformLocation(m_SolidRectShader, "u_Trans"), newX, newY, 0, size);
	glUniform4f(glGetUniformLocation(m_SolidRectShader, "u_Color"), r, g, b, a);

	int attribPosition = glGetAttribLocation(m_SolidRectShader, "a_Position");
	glEnableVertexAttribArray(attribPosition);
	glBindBuffer(GL_ARRAY_BUFFER, m_VBORect);
	glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);

	glDrawArrays(GL_TRIANGLES, 0, 6);

	glDisableVertexAttribArray(attribPosition);

	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void Renderer::DrawTriangle()
{
	// 시간을 초 단위로 흐르게 설정
	float gTime = glutGet(GLUT_ELAPSED_TIME) / 1000.0f;

	//Program select
	glUseProgram(m_TriangleShader);

	int uTime = glGetUniformLocation(m_TriangleShader, "u_Time");
	glUniform1f(uTime, gTime);

	int attribPosition = glGetAttribLocation(m_TriangleShader, "a_Position");
	int attribMass = glGetAttribLocation(m_TriangleShader, "a_Mass");
	int attribVel = glGetAttribLocation(m_TriangleShader, "a_Vel");
	int attribRV = glGetAttribLocation(m_TriangleShader, "a_RV");
	int attribRV1 = glGetAttribLocation(m_TriangleShader, "a_RV1");
	int attribRV2 = glGetAttribLocation(m_TriangleShader, "a_RV2");

	glEnableVertexAttribArray(attribPosition);
	if (attribMass != -1) glEnableVertexAttribArray(attribMass);
	if (attribVel != -1) glEnableVertexAttribArray(attribVel);
	if (attribRV != -1) glEnableVertexAttribArray(attribRV);
	if (attribRV1 != -1) glEnableVertexAttribArray(attribRV1);
	if (attribRV2 != -1) glEnableVertexAttribArray(attribRV2);

	glBindBuffer(GL_ARRAY_BUFFER, m_TriangleVBO);

	glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 9, 0);
	if (attribMass != -1) glVertexAttribPointer(attribMass, 1, GL_FLOAT, GL_FALSE, sizeof(float) * 9, (GLvoid*)(sizeof(float) * 3));
	if (attribVel != -1) glVertexAttribPointer(attribVel, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 9, (GLvoid*)(sizeof(float) * 4));
	if (attribRV != -1) glVertexAttribPointer(attribRV, 1, GL_FLOAT, GL_FALSE, sizeof(float) * 9, (GLvoid*)(sizeof(float) * 6));
	if (attribRV1 != -1) glVertexAttribPointer(attribRV1, 1, GL_FLOAT, GL_FALSE, sizeof(float) * 9, (GLvoid*)(sizeof(float) * 7));
	if (attribRV2 != -1) glVertexAttribPointer(attribRV2, 1, GL_FLOAT, GL_FALSE, sizeof(float) * 9, (GLvoid*)(sizeof(float) * 8));

	// 파티클 전체(m_ParticleCount)를 그리도록 변경
	glDrawArrays(GL_TRIANGLES, 0, m_ParticleCount);
}

void Renderer::DrawFS()
{
	// 시간을 초 단위로 흐르게 설정
	float gTime = glutGet(GLUT_ELAPSED_TIME) / 1000.0f;

	//Program select
	GLuint shader = m_FSShader;
	glUseProgram(shader);

	int uTime = glGetUniformLocation(shader, "u_Time");
	glUniform1f(uTime, gTime);
	int uPoints = glGetUniformLocation(shader, "u_Points");
	glUniform4fv(uPoints, 500, m_RainInfo);

	int attribPosition = glGetAttribLocation(shader, "a_Pos");
	int attribTex = glGetAttribLocation(shader, "a_Tex");

	glEnableVertexAttribArray(attribPosition);
	glEnableVertexAttribArray(attribTex);

	glBindBuffer(GL_ARRAY_BUFFER, m_FSVBO);

	glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, 0);
	glVertexAttribPointer(attribTex, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (GLvoid*)(sizeof(float)*3));

	glDrawArrays(GL_TRIANGLES, 0, 6);
}

void Renderer::GenParticles(int count)
{
	float centerx = 0;
	float centery = 0;
	float size = 0.01;
	float mass = 1;

	std::vector<float> particles;

	for (int i = 0; i < count; i++)
	{
		/*float vx = ((float)rand() / RAND_MAX - 0.5f) * 4.0f;
		float vy = ((float)rand() / RAND_MAX - 0.5f) * 4.0f;*/
		float vx = 0;
		float vy = 0;

		float rv = (rand() % 1000) / 1000.0f;
		float rv1 = (rand() % 1000) / 1000.0f;
		float rv2 = (rand() % 1000) / 1000.0f;

		float triangle[] =
		{
		 centerx - size / 2, centery - size / 2, 0, mass, vx, vy, rv, rv1,rv2,
		 centerx + size / 2, centery - size / 2, 0, mass, vx, vy, rv, rv1,rv2,
		 centerx + size / 2, centery + size / 2, 0, mass, vx, vy, rv, rv1,rv2,

		 centerx - size / 2, centery - size / 2, 0, mass, vx, vy, rv, rv1,rv2,
		 centerx + size / 2, centery + size / 2, 0, mass, vx, vy, rv, rv1,rv2,
		 centerx - size / 2, centery + size / 2, 0, mass, vx, vy, rv, rv1,rv2
		};

		particles.insert(particles.end(), triangle, triangle + 54);
	}

	if (m_TriangleVBO == 0)
	{
		glGenBuffers(1, &m_TriangleVBO);
	}

	glBindBuffer(GL_ARRAY_BUFFER, m_TriangleVBO);
	glBufferData(GL_ARRAY_BUFFER, particles.size() * sizeof(float), particles.data(), GL_STATIC_DRAW);

	m_ParticleCount = count * 6;
}

void Renderer::GetGLPosition(float x, float y, float* newX, float* newY)
{
	*newX = x * 2.f / m_WindowSizeX;
	*newY = y * 2.f / m_WindowSizeY;
}