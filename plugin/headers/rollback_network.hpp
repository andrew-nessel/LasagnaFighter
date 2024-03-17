#ifndef ROLLBACKNETWORK_H
#define ROLLBACKNETWORK_H

#include <godot_cpp/classes/node.hpp>
#include "headers/client.hpp"

namespace godot {

class RollbackNetwork : public Node {
	GDCLASS(RollbackNetwork, Node)

private:
	void emit_error(String msg);
	Client *client;

protected:
	static void _bind_methods();

public:
	RollbackNetwork();
	~RollbackNetwork();

	void _process(double delta) override;
	void start_client();
	void set_client(long addr, int port);
	void close_client();
	char* receive_message();
	void send_message(char msg[]);
};

}

#endif