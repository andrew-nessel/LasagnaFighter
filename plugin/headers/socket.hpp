#ifndef SOCKET_H
#define SOCKET_H

// #include <string.h> 
#include <winsock2.h>
// #include <sys/types.h>

// Windows uses winsock, but this doesn't work on other systems
// #ifdef __WIN32__
//     #include <winsock2.h>
// #else
//     #include <sys/socket.h>
// #endif


class Socket {

private:
    // SOCKET sockfd; 
    int sockfd;

public:
	Socket();
	~Socket();

    int open_socket();
    void close_socket();
    int bind_socket(SOCKADDR* server_addr, int server_len);

    SOCKET get_sockfd();
    // int get_sockfd();
};


#endif