#include "headers/client.hpp"
#include <ws2tcpip.h>

const int MAXLINE = 1024;

Client::Client(){
    // port = 8080;
    // port = 8080;
    portRetries = 3;
    server_len = sizeof(server_addr);
    client_len = sizeof(client_addr);
    memset(&server_addr, 0, server_len); 
    memset(&client_addr, 0, client_len); 
}

Client::~Client(){
    close_client();
}

Response Client::start_client(){

    WSADATA data;
    // To start WinSock, the required version must be passed to
	// WSAStartup(). This server is going to use WinSock version
	// 2 so I create a word that will store 2 and 2 in hex i.e.
	// 0x0202
	WORD version = MAKEWORD(2, 2);

	// Start WinSock
	int wsOk = WSAStartup(version, &data);
	if (wsOk != 0)
	{
		// Not ok! Get out quickly
		return Response(-1, Util::strConcat("Starting winsock failed - ", Util::getLastWSAError()));
	}

    int result = socket.open_socket();
    if (result == -1) {
        return Response(-1, Util::strConcat("opening socket failed - ", Util::getLastWSAError()));
    }

    // Filling server information 
    // server_addr.sin_family = AF_INET; // IPv4 
    // // server_addr.sin_addr.s_addr = INADDR_ANY; 
    // server_addr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
    // int retries = 3;
    
    result = -1;
    int x = 0;
    while((x < portRetries) && (result != 0)){
        server_addr.sin_port = port + x; 
        server_len = sizeof(server_addr);
        result = socket.bind_socket((SOCKADDR*)&server_addr, server_len);
        x++;
    }
    
    if (result == -1){
        return Response(-1, Util::strConcat("binding socket failed - ", Util::getLastWSAError()));
    }

    return Response(0, "success");
}

void Client::close_client(){
    socket.close_socket();
    WSACleanup();
}

void Client::set_client(const char * addr, int port){
    client_addr.sin_family = AF_INET; // IPv4 
    inet_pton(AF_INET, PCSTR(addr), &(client_addr.sin_addr));
    client_addr.sin_port = port; 
    client_len = sizeof(client_addr);
    // memset(&client_addr, 0, client_len); 
}

void Client::set_server(const char * addr, int port){
    this->port = port;
    server_addr.sin_family = AF_INET; // IPv4 
    inet_pton(AF_INET, PCSTR(addr), &(client_addr.sin_addr));
    server_addr.sin_port = port; 
    server_len = sizeof(server_addr);
    // memset(&client_addr, 0, client_len); 
}

Response Client::receive_message(){
    int recv_n;
    char buffer[MAXLINE]; 
    ZeroMemory(buffer, MAXLINE);
    // recv_n = -1;

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
        0, (struct sockaddr *) &client_addr, 
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

