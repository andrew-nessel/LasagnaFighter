#include "headers/socket.hpp"

#include <winsock2.h>

Socket::Socket(){
    sockfd = -1;
}

Socket::~Socket(){
    close_socket();
}

int Socket::open_socket(){

    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
        perror("socket creation failed"); 
        return -1;
    }

    return 0;
}

void Socket::close_socket(){
    if(sockfd != -1){
        closesocket(sockfd); //this is windows specific *sigh*
    }
}

int Socket::bind_socket(SOCKADDR* server_addr, int server_len){ // Bind the socket with the server address 

    if ( bind(sockfd, server_addr,  
            server_len) < 0 ) 
    { 
        perror("bind failed"); 
        return -1;
    } 

    return 0;
}

int Socket::get_sockfd(){
    return sockfd;
}