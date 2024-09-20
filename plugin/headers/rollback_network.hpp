#ifndef ROLLBACKNETWORK_H
#define ROLLBACKNETWORK_H

#include <godot_cpp/classes/node.hpp>
#include "headers/client.hpp"
#include "headers/util.hpp"
#include <thread>

namespace godot {

class RollbackNetwork : public Node {
	GDCLASS(RollbackNetwork, Node)

private:
	void emit_error(String msg);
	Client *client;
	String server_address;
	String external_address;
	int server_port;
	bool server_local;
	String client_address;
	int client_port;
	bool is_receiving;
	std::thread* rec_loop;

protected:
	static void _bind_methods();

public:
	RollbackNetwork();
	~RollbackNetwork();

	void _process(double delta) override;
	void start_client();
	void set_client();
	void set_server_address(String addr);
	String get_server_address();
	void set_external_address(String addr);
	String get_external_address();
	void set_server_port(int p);
	int get_server_port();
	void set_server_local(boolean isLocal);
	bool get_server_local();
	void set_client_address(String addr);
	String get_client_address();
	void set_client_port(int p);
	int get_client_port();
	void close_client();
	String receive_message();
	void send_message(String msg);
	// const char* StringToCString(String str);
	void start_receive_loop();
	void stop_receive_loop();
	void receive_loop();
	void receive_loop2();

};

}

#endif