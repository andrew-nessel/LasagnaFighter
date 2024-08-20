#ifndef CLIENT_H
#define CLIENT_H

#include "socket.hpp"
#include "response.hpp"
#include "util.hpp"

class Client {

private:
    Socket socket;
	int port;
	struct sockaddr_in server_addr;
	int server_len;
    struct sockaddr_in client_addr;
    int client_len;
	int portRetries;

public:
	Client();
	~Client();

	Response start_client();
	void close_client();
	void set_client(const char * addr, int port);
	void set_server(const char * addr, int port);
	Response receive_message();
	Response send_message(const char * msg);
	const char* get_server_address();
	int get_server_port();
};


#endif