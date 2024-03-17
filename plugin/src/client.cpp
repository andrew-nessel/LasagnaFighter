#include "headers/client.hpp"

const int MAXLINE = 1024;

Client::Client(){
    port = 8080;

    server_len = sizeof(server_addr);
    client_len = sizeof(client_addr);
    memset(&server_addr, 0, server_len); 
    memset(&client_addr, 0, client_len); 
}

Client::~Client(){
    close_client();
}

void Client::start_client(){

    int result = socket.open_socket();
    if (result == -1) {
        return;
    }

    // Filling server information 
    server_addr.sin_family = AF_INET; // IPv4 
    server_addr.sin_addr.s_addr = INADDR_ANY; 
    server_addr.sin_port = htons(port); 

    result = socket.bind_socket((SOCKADDR*) &server_addr, server_len);
    if (result == -1){
        return;
    }
}

void Client::close_client(){
    socket.close_socket();
}

void Client::set_client(long addr, int port){
    client_addr.sin_family = AF_INET; // IPv4 
    client_addr.sin_addr.s_addr = addr; 
    client_addr.sin_port = port; 
}

char* Client::receive_message(){
    int recv_n;
    char buffer[MAXLINE]; 

    recv_n = recvfrom(socket.get_sockfd(), static_cast<char *>(buffer), MAXLINE,  
                MSG_WAITALL, ( struct sockaddr *) &client_addr, 
                &client_len);
    buffer[recv_n] = '\0'; 

    return buffer;
}

void Client::send_message(char msg[]){
    sendto(socket.get_sockfd(), static_cast<const char *>(msg), strlen(msg),  
        0, (const struct sockaddr *) &client_addr, 
            client_len);
}