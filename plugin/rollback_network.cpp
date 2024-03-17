#include "headers/rollback_network.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void RollbackNetwork::_bind_methods() {
	ADD_SIGNAL(MethodInfo("client_started", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("client_closed", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("message_received", PropertyInfo(Variant::STRING, "msg"), PropertyInfo(Variant::STRING, "info")));
	ADD_SIGNAL(MethodInfo("message_sent", PropertyInfo(Variant::STRING, "msg"), PropertyInfo(Variant::STRING, "info")));
	ADD_SIGNAL(MethodInfo("error", PropertyInfo(Variant::STRING, "error")));
}

RollbackNetwork::RollbackNetwork() {
	// Initialize any variables here.
	client = NULL;
}

RollbackNetwork::~RollbackNetwork() {
	// Add your cleanup here.
}

void RollbackNetwork::_process(double delta) {
	// time_passed += delta;

	// Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));

	// emit_signal("server_started", true, "");
}

void RollbackNetwork::start_client(){
	client = new Client();
	client->start_client();
}

void RollbackNetwork::set_client(long addr, int port){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}
	client->set_client(addr, port);
}

void RollbackNetwork::close_client(){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}
	client->close_client();
}

char* RollbackNetwork::receive_message(){
	if(client == NULL){
		emit_error("client not set up...");
		return NULL;
	}
	char* msg = client->receive_message();
	return msg;
}

void RollbackNetwork::send_message(char msg[]){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}
	client->send_message(msg);
}

void RollbackNetwork::emit_error(String msg){
	emit_signal("error", msg);
}