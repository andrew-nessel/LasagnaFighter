#ifndef RESPONSE_H
#define RESPONSE_H

class Response {

private:
    int status;
    const char* msg;
public:
	Response();
	Response(int s, const char* m);
	~Response();

    int getStatus();
    const char* getMsg();
};




#endif