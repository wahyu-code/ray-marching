#ifndef _DEMO_RAY_MARCHING_HPP
#define _DEMO_RAY_MARCHING_HPP
#include <misc/type.hpp>
#include <glad/glad.h>
#include <shader/shader.hpp>
#include <glfw/glfw3.h>
// void init();
struct Vertex
{
    f32 x, y, z;
};
class RayMarchingDemo
{
private:
    u32 m_vao;
    u32 m_vbo;
    u32 m_ebo;

public:
    RayMarchingDemo()
    {
        glGenVertexArrays(1, &m_vao);
        glGenBuffers(1, &m_vbo);
        glGenBuffers(1, &m_ebo);
        Vertex vertices[] = {
            {.75f, .75f, 0},
            {.75f, -.75f, 0},
            {-.75f, -.75f, 0},
            {-.75f, .75f, 0}};
        u32 indices[] = {0, 1, 2,
                         0, 2, 3};
        glBindVertexArray(m_vao);

        glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), static_cast<void *>(vertices), GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), static_cast<void *>(indices), GL_STATIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)0);
        glEnableVertexAttribArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
    void draw(Program &shader)
    {
        shader.use();
        i32 uniform = shader.getUniformLoc("iTime");
        float time = glfwGetTime();
        glUniform1f(uniform, time);
        glBindVertexArray(m_vao);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        glBindVertexArray(0);
        shader.unUse();
    }
    ~RayMarchingDemo()
    {
        glDeleteVertexArrays(1, &m_vao);
        glDeleteBuffers(1, &m_vbo);
        glDeleteBuffers(1, &m_ebo);
    }
};
#endif