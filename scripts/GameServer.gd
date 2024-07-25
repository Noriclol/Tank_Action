extends Node
class_name GameServer


@onready var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var game_scene : PackedScene
@export var debug_line : String

func create_server(port : int) -> bool:
	var server = peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	if server == OK:
		debug_line = "Server"
		init_map()
		$Menu/Connect_Menu.hide()
		#$Level/GameMap/UserInterface/HUD/infoLabel.text = "Server started on port: " + str(port)
		return true
	else:
		return false


func create_client(adress: String, port : int) -> bool:
	var client = peer.create_client(adress, port)
	multiplayer.multiplayer_peer = peer
	if client == OK:
		debug_line = "Client"
		$Menu/Connect_Menu.hide()
		#$Level/GameMap/UserInterface/HUD/infoLabel.text = "Connected to server: " + adress + " on port: " + str(port)
		return true
	else:
		return false


func init_map():
	print("init_map")
	if multiplayer.is_server():
		var level = $Level
		var map = game_scene.instantiate()

		level.call_deferred("add_child",map)


