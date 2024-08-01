#include "headers/rollback_network.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void RollbackNetwork::_bind_methods() {
	ADD_SIGNAL(MethodInfo("client_started", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("client_closed", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error")));
	ADD_SIGNAL(MethodInfo("message_received", PropertyInfo(Variant::STRING, "msg"), PropertyInfo(Variant::STRING, "info")));
	ADD_SIGNAL(MethodInfo("message_sent", PropertyInfo(Variant::STRING, "msg"), PropertyInfo(Variant::STRING, "info")));
	ADD_SIGNAL(MethodInfo("error", PropertyInfo(Variant::STRING, "error")));

	ClassDB::bind_method(D_METHOD("start_client"), &RollbackNetwork::start_client);
	ClassDB::bind_method(D_METHOD("close_client"), &RollbackNetwork::close_client);
	ClassDB::bind_method(D_METHOD("start_receive_loop"), &RollbackNetwork::start_receive_loop);
	ClassDB::bind_method(D_METHOD("stop_receive_loop"), &RollbackNetwork::stop_receive_loop);
	ClassDB::bind_method(D_METHOD("set_client"), &RollbackNetwork::set_client);
	ClassDB::bind_method(D_METHOD("set_server_address"), &RollbackNetwork::set_server_address);
	ClassDB::bind_method(D_METHOD("get_server_address"), &RollbackNetwork::get_server_address);
	ClassDB::bind_method(D_METHOD("set_server_port"), &RollbackNetwork::set_server_port);
	ClassDB::bind_method(D_METHOD("get_server_port"), &RollbackNetwork::get_server_port);
	ClassDB::add_property("RollbackNetwork", PropertyInfo(Variant::STRING, "server_address"), "set_server_address", "get_server_address");
	ClassDB::add_property("RollbackNetwork", PropertyInfo(Variant::INT, "server_port"), "set_server_port", "get_server_port");
	ClassDB::bind_method(D_METHOD("set_client_address"), &RollbackNetwork::set_client_address);
	ClassDB::bind_method(D_METHOD("get_client_address"), &RollbackNetwork::get_client_address);
	ClassDB::bind_method(D_METHOD("set_client_port"), &RollbackNetwork::set_client_port);
	ClassDB::bind_method(D_METHOD("get_client_port"), &RollbackNetwork::get_client_port);
	ClassDB::add_property("RollbackNetwork", PropertyInfo(Variant::STRING, "client_address"), "set_client_address", "get_client_address");
	ClassDB::add_property("RollbackNetwork", PropertyInfo(Variant::INT, "client_port"), "set_client_port", "get_client_port");
	ClassDB::bind_method(D_METHOD("send_message"), &RollbackNetwork::send_message);

	// ClassDB::bind_method(D_METHOD("receive_message"), &RollbackNetwork::receive_message);
	// ClassDB::bind_method(D_METHOD("send_message", "msg"), &RollbackNetwork::set_client);
}

RollbackNetwork::RollbackNetwork() : client_address("0.0.0.0"), server_address("10.0.0.0"){
	// Initialize any variables here.
	client = NULL;
	client_port = 8080;
	// client_address = "0.0.0.0";
	server_port = 8080;
	// server_address = "10.0.0.0";
	is_receiving = false;
	rec_loop = NULL;
}

RollbackNetwork::~RollbackNetwork() {
	// Add your cleanup here.
	if(is_receiving){
		if(rec_loop != NULL){
			stop_receive_loop();
			if(rec_loop->joinable()){
				rec_loop->join();
			}
		}
	}
	
}

void RollbackNetwork::_process(double delta) {
	// time_passed += delta;

	// Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));

	// emit_signal("server_started", true, "");
	// String s("");
	// s = receive_message();
	// if (s == ""){
	// 	return;
	// }
	// emit_signal("message_received", s, "");
}

void RollbackNetwork::start_client(){
	client = new Client();
	Response r = client->start_client();
	if(r.getStatus() == -1){
		emit_error(String(r.getMsg()));
		return;
	}
	server_address = String(client->get_server_address());
	server_port = client->get_server_port();
	emit_signal("client_started", true, "");
}

void RollbackNetwork::set_client(){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}
	client->set_client(Util::StringToCString(client_address), client_port);
}

void RollbackNetwork::set_server_address(String addr){
	server_address = addr;
	return;
}

String RollbackNetwork::get_server_address(){
	return server_address;
}

void RollbackNetwork::set_server_port(int p){
	server_port = p;
	return;
}

int RollbackNetwork::get_server_port(){
	return server_port;
}

void RollbackNetwork::set_client_address(String addr){
	client_address = addr;
	return;
}

String RollbackNetwork::get_client_address(){
	return client_address;
}

void RollbackNetwork::set_client_port(int p){
	client_port = p;
	return;
}

int RollbackNetwork::get_client_port(){
	return client_port;
}

void RollbackNetwork::close_client(){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}
	client->close_client();
}

void RollbackNetwork::start_receive_loop(){
	if(is_receiving){
		return;
	}
	is_receiving = true;
	// std::thread(&RollbackNetwork::receive_loop2, this);
	rec_loop = new std::thread(&RollbackNetwork::receive_loop, this);
	rec_loop->detach();
	// rec_loop = &t1;
}

void RollbackNetwork::stop_receive_loop(){
	is_receiving = false;
}

void RollbackNetwork::receive_loop2(){
	return;
}

void RollbackNetwork::receive_loop(){
	while(is_receiving){
		String s("");
		s = receive_message();
		if (s == ""){
			continue;
		}
		emit_signal("message_received", s, "");
	}
}

String RollbackNetwork::receive_message(){
	// emit_signal("client_started", true, "");
	if(client == NULL){
		emit_error("client not set up...");
		return "";
	}
	Response msg = client->receive_message();
	if(msg.getStatus() < 0){
		emit_error(msg.getMsg());
		return "";
	}
	return String(msg.getMsg());
}

void RollbackNetwork::send_message(String msg){
	if(client == NULL){
		emit_error("client not set up...");
		return;
	}

	Response r = client->send_message(Util::StringToCString(msg));
	if(r.getStatus() < 0){
		emit_error(r.getMsg());
		return;
	}
	std::string s = std::to_string(client_port);
	String p(s.c_str());
	emit_signal("message_sent", msg, "address: " + client_address + ", port:" + p);
}

void RollbackNetwork::emit_error(String msg){
	emit_signal("error", msg);
}

// const char* RollbackNetwork::StringToCString(String str){
// 	return str.utf8().get_data();
// }

// String CStringToString(const char* str){
// 	String s(str);
// 	return s;
// }