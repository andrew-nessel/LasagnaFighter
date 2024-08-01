#include "headers/response.hpp"


Response::Response(){
    status = -1;
    msg = "";
}

Response::Response(int s, const char* m){
    status = s;
    msg = m;
}

Response::~Response(){
}

int Response::getStatus(){
    return status;
}

const char* Response::getMsg(){
    return msg;
}

