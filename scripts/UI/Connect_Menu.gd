extends Control
class_name Connect_Menu

@onready var serverJoinAddressContainer : LineEdit = %ServerJoinAddress
@onready var serverJoinPortContainer : LineEdit = %ServerJoinPort
@onready var custom_tank_name : LineEdit = %CustomTankName

signal create_server(port : int)
signal create_client(address : String, port : int)


func _on_host_pressed():
	create_server.emit(serverJoinPortContainer.text.to_int())
	get_window().title = "Host"


func _on_join_pressed():
	create_client.emit(serverJoinAddressContainer.text, serverJoinPortContainer.text.to_int())
	get_window().title = "Client"


