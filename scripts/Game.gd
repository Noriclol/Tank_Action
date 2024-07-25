extends Node2D
class_name Game

@onready var player_spawn : Node2D = %Players
@onready var select_team_menu : Select_Team_Menu = $UserInterface/Select_Team_Menu


var spawned_players = {}

signal player_added(player: Player)
signal player_removed(player_id: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game scene ready on peer: ", multiplayer.get_unique_id())
	cleanup_players()

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	if multiplayer.is_server():
		add_player(1)

	for id in multiplayer.get_peers():
		add_player(id)


# func _exit_tree():
# 	if not multiplayer.is_server():
# 		return
# 	multiplayer.peer_connected.disconnect(add_player)
# 	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	if not multiplayer.is_server():
		return
	print("Adding player with id: ", id, " on peer: ", multiplayer.get_unique_id())

	var player_name = "Player:" + str(id)
	if player_spawn.has_node(player_name):
		print("Player " + str(id) + " already exists, not spawning again.")
		return

	var new_player = preload("res://scenes/Player/player.tscn").instantiate()
	player_spawn.call_deferred("add_child",new_player)
	new_player.init(id)
	new_player.add_to_group("players") 
	spawned_players[id] = new_player

	player_added.emit(new_player)

func del_player(id: int):
	if not player_spawn.has_node(str(id)):
		return
	player_spawn.get_node(str(id)).queue_free()
	spawned_players.erase(id)
	player_removed.emit(id)


func cleanup_players():
	for child in player_spawn.get_children():
		child.queue_free()
	spawned_players.clear()


func get_local_player() -> Player:
	return spawned_players[multiplayer.get_unique_id()]

func start_game():
	if not multiplayer.is_server():
		return
	
	for player in spawned_players.values():
		if player.get_team() == "Spectator":
			print("Not all players have selected a team. Cannot start the game.")
			return
	
	# Hide the team selection menu
	select_team_menu.hide()
	
	# Spawn tanks for each player
	for player in spawned_players.values():
		print("Spawning tank for player: ", player.player_id)


	
