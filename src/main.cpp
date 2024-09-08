#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <openglErrorReporting.h>
#include <shader/shader.hpp>
#include <demo/ray-marching.hpp>
static void error_callback(int error, const char *description)
{
	std::cout << "Error: " << description << "\n";
}

int main(void)
{
	glfwSetErrorCallback(error_callback);
	if (!glfwInit())
	{
		exit(EXIT_FAILURE);
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
	GLFWwindow *window = glfwCreateWindow(640, 640, "Template sederhana", NULL, NULL);
	if (!window)
	{
		glfwTerminate();
		exit(EXIT_FAILURE);
	}
	glfwMakeContextCurrent(window);
	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
	{
		glfwTerminate();
		exit(EXIT_FAILURE);
	}
	enableReportGlErrors();
	// glfwMaximizeWindow(window);
	// int w, h;
	// glfwGetFramebufferSize(window, &w, &h);
	// std::cout << h << " " << w << std::endl;
	int ar[2];
	glClearColor(1, 1, 1, 1);
	RayMarchingDemo rayMarching;
	Program shader;
	shader.load("assets/shader/vert.glsl", "assets/shader/frag.glsl");

	while (!glfwWindowShouldClose(window))
	{
		int width = 0, height = 0;
		glfwGetFramebufferSize(window, &width, &height);
		glViewport(0, 0, width, height);
		glClear(GL_COLOR_BUFFER_BIT);
		rayMarching.draw(shader);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwDestroyWindow(window);
	glfwTerminate();
	return 0;
}
