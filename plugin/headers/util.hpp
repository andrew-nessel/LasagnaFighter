#ifndef UTIL_H
#define UTIL_H

#include <godot_cpp/core/class_db.hpp>
#include <ws2tcpip.h>

// Utility class to manage misc. functions

class Util {
public:
    // static std::string serialize_http_args(std::map<std::string, std::string>);
    // static std::string serialize_http_headers(std::map<std::string, std::string>);
    // static int randrange(int min, int max);
    // static void trim(std::string&);
    // static void ltrim(std::string&);
    // static void rtrim(std::string&);
    // static std::string trim_copy(std::string);
    // static std::string ltrim_copy(std::string);
    // static std::string rtrim_copy(std::string);
    // static std::string int2str(int);
    // static std::string lowercase(std::string);
    // static std::vector<std::string> split(std::string, std::string);
    // static std::vector<std::string> split_once(std::string, std::string);
    static const char* StringToCString(godot::String str);
    static godot::String CStringToString(const char* str);
    static char* getLastWSAError();
    static char* Util::strConcat(char* a, char* b);
};

#endif