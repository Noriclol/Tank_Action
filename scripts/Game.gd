extends Node2D
class_name Game
@onready var player_spawn : Node2D = %Players

var spawned_players = {}

# Called when the node enters the scene tree for the first time.
func _ready():

	# if not multiplayer.is_server():
	# 	client_ready.rpc_id(1)

	print("Game scene ready on peer: ", multiplayer.get_unique_id())
	cleanup_players()
	# We only need to spawn players on the server.
	# if not multiplayer.is_server():
	# 	return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)



	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)
	
	# # Spawn the player for the server
	if multiplayer.is_server():
		add_player(1)




func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	if not multiplayer.is_server():
		return
	print("Adding player with id: ", id, " on peer: ", multiplayer.get_unique_id())

	var player_name = "Player:" + str(id)
	if player_spawn.has_node(player_name):
		print("Player " + str(id) + " already exists, not spawning again.")
		return

	var new_player = preload("res://scenes/Player/player.tscn").instantiate()
	# Set player id.

	player_spawn.call_deferred("add_child",new_player)
	new_player.player_team = 2
	new_player.tank_name = "Tank " + str(id)
	new_player.name = player_name
	new_player.player_id = id
	spawned_players[id] = new_player
	print("Player added successfully: ", id)
	print("__________________________________________")

func del_player(id: int):
	if not player_spawn.has_node(str(id)):
		return
	player_spawn.get_node(str(id)).queue_free()


func cleanup_players():
	for child in player_spawn.get_children():
		child.queue_free()


# @rpc("any_peer")
# func client_ready():
# 	if multiplayer.is_server():
# 		var id = multiplayer.get_remote_sender_id()
# 		add_player(id)