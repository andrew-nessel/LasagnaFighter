#include "headers/util.hpp"

const char* Util::StringToCString(godot::String str){
	return str.utf8().get_data();
}

godot::String Util::CStringToString(const char* str){
	godot::String s(str);
	return s;
}

char* Util::getLastWSAError(){
    // wchar_t *s = NULL;
    LPWSTR pBuffer = NULL;
    // char msgbuf [256];
    // msgbuf [0] = '\0'; 
    // FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, 
    //            NULL, WSAGetLastError(),
    //            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    //            pBuffer, 0, NULL);

    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, 
    NULL, GetLastError(),
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    pBuffer, 0, NULL);

    // GetLastError()
    if(pBuffer == NULL){
        return " error not found";
    }
    static char buffer[32];
    int ret;
    ret = wcstombs(buffer, pBuffer, sizeof(buffer) );
    if (ret==32){
        buffer[31]='\0';
    }
    return buffer;
}

char* Util::strConcat(char* a, char* b){
    char* x = new char[strlen(a) + strlen(b) + 1];
    strcpy( x, a);
    strcat( x, b);
    return x;
}
