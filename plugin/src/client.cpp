#include "headers/client.hpp"
#include <ws2tcpip.h>

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

Response Client::start_client(){

    int result = socket.open_socket();
    if (result == -1) {
        return Response(-1, Util::strConcat("opening socket failed - ", Util::getLastWSAError()));
    }

    // Filling server information 
    server_addr.sin_family = AF_INET; // IPv4 
    server_addr.sin_addr.s_addr = INADDR_ANY; 
    server_addr.sin_port = htons(port); 

    result = socket.bind_socket((SOCKADDR*) &server_addr, server_len);
    if (result == -1){
        return Response(-1, Util::strConcat("binding socket failed - ", Util::getLastWSAError()));
    }
    return Response(0, "success");
}

void Client::close_client(){
    socket.close_socket();
}

void Client::set_client(const char * addr, int port){
    client_addr.sin_family = AF_INET; // IPv4 
    inet_pton(AF_INET, PCSTR(addr), &(client_addr.sin_addr));
    client_addr.sin_port = port; 
    client_len = sizeof(client_addr);
    memset(&client_addr, 0, client_len); 
}

Response Client::receive_message(){
    int recv_n;
    char buffer[MAXLINE]; 
    ZeroMemory(buffer, MAXLINE);
    // recv_n = -1;

    set_client("127.0.0.1", 36895);

    recv_n = recvfrom(socket.get_sockfd(), buffer, MAXLINE,  
                0, ( struct sockaddr *) &client_addr, 
                &client_len);
    
    if(recv_n == SOCKET_ERROR){
        return Response(-1, Util::strConcat("receive failed - ", Util::getLastWSAError()));
    }
    buffer[recv_n] = '\0'; 

    return Response(0, buffer);
}

Response Client::send_message(const char * msg){
    int stat = sendto(socket.get_sockfd(), msg, strlen(msg),  
        0, (const struct sockaddr *) &client_addr, 
            client_len);
    if(stat < 0){
        return Response(-1, Util::strConcat("send failed - ", Util::getLastWSAError()));
    }
    return Response(0, "success");
}

const char* Client::get_server_address(){
    char str[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &(server_addr.sin_addr), str, INET_ADDRSTRLEN);
    return str;
}

int Client::get_server_port(){
    return static_cast<int>(server_addr.sin_port);
}

