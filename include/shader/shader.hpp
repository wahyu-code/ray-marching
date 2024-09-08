#ifndef _SHADER_SHADER_H
#define _SHADER_SHADER_H
#include <glad/glad.h>
#include <misc/type.hpp>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>

u32 myLoadShader(std::string const &file_path, GLenum shader_type)
{
    std::ifstream file(file_path);

    if (!file.is_open())
    {
        std::cerr << "error open shader file :" << file_path << std::endl;
        return 0;
    }
    std::stringstream ss;
    ss << file.rdbuf();
    std::string src(ss.str());
    const char *psrc = src.c_str();

    u32 shader = glCreateShader(shader_type);
    glShaderSource(shader, 1, &psrc, nullptr);
    glCompileShader(shader);
    i32 success;
    char info_log[512];
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

    if (!success)
    {
        glGetShaderInfoLog(shader, 512, nullptr, info_log);
        std::cout << file_path << std::endl;
        std::cout << info_log << std::endl;
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}
class Program
{
    u32 m_program = 0;

public:
    void use()
    {
        glUseProgram(m_program);
    }
    void unUse()
    {
        glUseProgram(0);
    }
    void load(std::string const &vert_file, std::string const &frag_file)
    {
        u32 vert = myLoadShader(vert_file, GL_VERTEX_SHADER);
        u32 frag = myLoadShader(frag_file, GL_FRAGMENT_SHADER);
        m_program = glCreateProgram();
        glAttachShader(m_program, vert);
        glAttachShader(m_program, frag);
        glLinkProgram(m_program);
        i32 success;
        glGetProgramiv(m_program, GL_LINK_STATUS, &success);
        char info_log[512];
        if (!success)
        {
            glGetProgramInfoLog(m_program, 512, nullptr, info_log);
            std::cout << "linking error\n"
                      << info_log << std::endl;
        }
        glDeleteShader(vert);
        glDeleteShader(frag);
    }
    i32 getUniformLoc(const char *uniform)
    {
        return glGetUniformLocation(m_program, uniform);
    }
    ~Program()
    {
        glDeleteProgram(m_program);
    }
};

#endif