#ifndef CLIENT_H
#define CLIENT_H

#include "socket.hpp"
#include "response.hpp"
#include "util.hpp"

class Client {

private:
    Socket socket;
    Socket socket2;
	int port;
	bool is_local;
	const char* external_address;
	const char* server_address;
	struct addrinfo* server_addr;
	int server_len;
    struct addrinfo* client_addr;
    int client_len;
	int portRetries;

public:
	Client();
	~Client();

	Response start_client();
	void close_client();
	Response set_client(const char * addr, int port);
	Response set_server(const char * addr, int port);
	Response receive_message();
	Response send_message(const char * msg);
	const char* get_server_address();
	int get_server_port();
	void set_local(bool isLocal);
	Response get_external_ip();
	const char* get_external_address();
};


#endif