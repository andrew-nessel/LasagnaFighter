#include "headers/client.hpp"
#include <ws2tcpip.h>
#include <string.h>
#include <vector>
#include <locale>
#include <sstream>

const int MAXLINE = 1024;
std::string url = "api6.ipify.org";

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
        result = socket.bind_socket_info(server_addr);
        x++;
    }
    // freeaddrinfo(server_addr); //todo we have to free the server addr everytime we try to bind it, then reconstruct it if we need to rebind...
    
    if (result == -1){
        return Response(-1, Util::strConcat("binding socket failed - ", Util::getLastWSAError()));
    }

    result = socket2.open_socket();
    if (result == -1) {
        return Response(-1, Util::strConcat("opening socket failed - ", Util::getLastWSAError()));
    }

    // Filling server information 
    // server_addr.sin_family = AF_INET; // IPv4 
    // // server_addr.sin_addr.s_addr = INADDR_ANY; 
    // server_addr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
    // int retries = 3;
    
    result = -1;
    x = 0;
    while((x < portRetries) && (result != 0)){
        result = socket2.bind_socket_info(server_addr);
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

Response Client::set_client(const char * addr, int port){
    // server_addr.sin_family = AF_INET; // IPv4 
    // inet_pton(AF_INET, PCSTR(addr), &(client_addr.sin_addr));
    // client_addr.sin_port = port; 
    // server_addr.sin6_family = AF_INET6; // IPv6
    // client_addr.sin6_port = port; 
    // inet_pton(AF_INET6, PCSTR(addr), &(client_addr.sin6_addr));

    addrinfo hint = {};
    // addrinfo * addri = NULL;
    hint.ai_flags = AI_PASSIVE | AI_NUMERICHOST;
    hint.ai_family = AF_INET6;
    hint.ai_socktype = SOCK_DGRAM;
    hint.ai_protocol = IPPROTO_UDP;
    char const* cport = std::to_string(port).c_str();
    client_addr = NULL;

    int res = getaddrinfo(addr, cport, &hint, &client_addr);
    if(res < 0){
        return Response(res, Util::strConcat("set client failed - ", Util::getLastWSAError()));
    }

    return Response(0, "client set success");
    // client_len = sizeof(client_addr);
    // memset(&client_addr, 0, client_len); 
}

Response Client::set_server(const char * addr, int port){
    this->port = port;
    // server_addr.sin_family = AF_INET; // IPv4 
    // if(is_local){
    //     server_addr.sin_addr.S_un.S_addr = INADDR_LOOPBACK; 
    // }else{
    //     server_addr.sin_addr.s_addr = INADDR_ANY; // Set to remote address
    // }
    // server_addr.sin_port = port;
    // server_addr.sin6_family = AF_INET6; // IPv6
    addrinfo hint = {};
    // addrinfo * addri = NULL;
    hint.ai_flags = AI_PASSIVE | AI_NUMERICHOST;
    hint.ai_family = AF_INET6;
    hint.ai_socktype = SOCK_DGRAM;
    hint.ai_protocol = IPPROTO_UDP;
    char const* cport = std::to_string(port).c_str();
    server_addr = NULL;

    int res = getaddrinfo(addr, cport, &hint, &server_addr);
    if(res < 0){
        return Response(res, Util::strConcat("set server failed - ", Util::getLastWSAError()));
    }

    server_address = addr;

    return Response(0, "server set success");

    // if(is_local){
    //     server_addr.sin6_addr.s6_addr = INADDR_LOOPBACK; 
    // }else{
    //     server_addr.sin6_addr.s6_addr = INADDR_ANY; // Set to remote address
    // }
    // server_addr.sin6_port = port; 
    // server_len = sizeof(server_addr);
    // memset(&client_addr, 0, client_len); 
}

Response Client::receive_message(){
    int recv_n;
    char buffer[MAXLINE]; 
    ZeroMemory(buffer, MAXLINE);
    // recv_n = -1;

    // struct sockaddr_in recAddr;
    // int recAddrLen = sizeof(recAddr);
    // ZeroMemory(&recAddr, recAddrLen);

    // recv_n = recvfrom(socket.get_sockfd(), buffer, MAXLINE,  
    //             0, (SOCKADDR *) &recAddr, &recAddrLen);

    recv_n = recvfrom(socket2.get_sockfd(), buffer, MAXLINE,  
                0, client_addr->ai_addr,  
            (int *) &client_addr->ai_addrlen);

    // recv_n = recv(socket.get_sockfd(), buffer, MAXLINE, 0);
    
    if(recv_n == SOCKET_ERROR){
        return Response(-1, Util::strConcat("receive failed - ", Util::getLastWSAError()));
    }
    buffer[recv_n] = '\0'; 

    return Response(0, buffer);
}

Response Client::send_message(const char * msg){
    int stat = sendto(socket.get_sockfd(), msg, strlen(msg),  
        0, client_addr->ai_addr,  
            client_addr->ai_addrlen);
    if(stat < 0){
        return Response(-1, Util::strConcat("send failed - ", Util::getLastWSAError()));
    }
    return Response(0, "success");
}

const char* Client::get_server_address(){
    // server_address = server_addr->ai_addr->sa_data;
    LPSOCKADDR sockaddr_ip = (LPSOCKADDR) server_addr->ai_addr;
    struct sockaddr_in6 * sockaddr_ipv6;
    DWORD ipbufferlength = 46;
    char ipstringbuffer[46];
    wchar_t* ipwstringbuffer[46];
    char* sa = "";
    struct sockaddr_in * sockaddr_ipv4;
    INT iRetval;
    server_address = "nothing happens";

    switch (server_addr->ai_family) {
            case AF_UNSPEC:
                server_address = "Unspecified";
                break;
            case AF_INET:
                sockaddr_ipv4 = (struct sockaddr_in *) server_addr->ai_addr;
                server_address = inet_ntoa(sockaddr_ipv4->sin_addr);
                server_address = "ipv4";
                break;
            case AF_INET6:
                // printf("AF_INET6 (IPv6)\n");
                // the InetNtop function is available on Windows Vista and later
                sockaddr_ipv6 = (struct sockaddr_in6 *) server_addr->ai_addr;
                // printf("\tIPv6 address %s\n",
                //    InetNtop(AF_INET6, &sockaddr_ipv6->sin6_addr, ipstringbuffer, 46) );

                InetNtop(AF_INET6, &sockaddr_ipv6->sin6_addr, ipwstringbuffer, 46);
                wcstombs(sa, ipwstringbuffer, ipbufferlength);
                server_address = sa;
                // server_address = ipstringbuffer;                
                // We use WSAAddressToString since it is supported on Windows XP and later
                // LPSOCKADDR sockaddr_ip = (LPSOCKADDR) server_addr->ai_addr;
                // The buffer length is changed by each call to WSAAddresstoString
                // So we need to set it for each iteration through the loop for safety
                // DWORD ipbufferlength = 46;
                // wchar_t ipstringbuffer[46];

                // char* sa = "";
                // iRetval = WSAAddressToStringA(sockaddr_ip, (DWORD) server_addr->ai_addrlen, NULL, 
                //     (LPSTR) ipstringbuffer, &ipbufferlength );
                // if (iRetval)
                //     server_address = "WSAAddressToString failed with %u\n" + WSAGetLastError();
                // else
                //     // wcstombs(sa, (wchar_t *) ipstringbuffer, ipbufferlength);
                //     // server_address = sa;
                //     server_address = ipstringbuffer;
                    
                // server_address = "ipv6";
                break;
            default:
                server_address = "other...";
                break;
        }

    return server_address;
}

int Client::get_server_port(){
    return port;
}

void Client::set_local(bool isLocal){
    is_local = isLocal;
}

//This is based on this stack overflow answer: https://stackoverflow.com/questions/39566240/how-to-get-the-external-ip-address-in-c
//at some point I would like this to instead use a different method that doesn't rely on an external site
//and that shows the ip and port as a obfuscated code for the player to just copy and paste into an easier input...
Response Client::get_external_ip(){
    std::string website_HTML;
    std::locale local;
    char lineBuffer[200][80] ={' '};
    char buffer[10000];
    char ip_address[16];
    SOCKADDR_IN SockAddr;
    struct hostent *host;
    std::string get_http;


    get_http = "GET / HTTP/1.1\r\nHost: " + url + "\r\nConnection: close\r\n\r\n";
    host = gethostbyname(url.c_str());
    Socket tcpsocket = Socket();
    tcpsocket.open_tcp_socket();

    SockAddr.sin_port=htons(80);
    SockAddr.sin_family=AF_INET;
    SockAddr.sin_addr.s_addr = *((unsigned long*)host->h_addr);

    if(connect(tcpsocket.get_sockfd(),(SOCKADDR*)(&SockAddr),sizeof(SockAddr)) != 0){
        return Response(-1, "Could not connect");
    }
    send(tcpsocket.get_sockfd(),get_http.c_str(), strlen(get_http.c_str()),0 );

    int nDataLength;
    while ((nDataLength = recv(tcpsocket.get_sockfd(),buffer,10000,0)) > 0){        
        int i = 0;
        while (buffer[i] >= 32 || buffer[i] == '\n' || buffer[i] == '\r'){

            website_HTML+=buffer[i];
            i += 1;
        }               
    }
    for (size_t i=0; i<website_HTML.length(); ++i) website_HTML[i]= tolower(website_HTML[i],local);

    std::istringstream ss(website_HTML);
    std::string stoken;
    int lineIndex=0;
    while(getline(ss, stoken, '\n')) {

              strcpy(lineBuffer[lineIndex],stoken.c_str());
              int dot=0;
              for (int ii=0; ii< strlen( lineBuffer[lineIndex] ); ii++ ){

                  if (lineBuffer[lineIndex][ii] == '.') dot++;
                  if (dot>=3){
                      dot=0;
                      strcpy(ip_address,lineBuffer[lineIndex]);
                  }
              }
              lineIndex++;
     }

    tcpsocket.close_socket();
    external_address = ip_address;
    return Response(0, ip_address);
}

const char* Client::get_external_address(){
    return external_address;
}
