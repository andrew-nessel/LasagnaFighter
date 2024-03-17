#ifndef CLIENT_H
#define CLIENT_H

#include "socket.hpp"

class Client {

private:
    Socket socket;
	int port;
	struct sockaddr_in server_addr;
	int server_len;
    struct sockaddr_in client_addr;
    int client_len;

public:
	Client();
	~Client();

	void start_client();
	void close_client();
	void set_client(long addr, int port);
	char* receive_message();
	void send_message(char msg[]);
};


#endif