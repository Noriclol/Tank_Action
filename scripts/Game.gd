extends Node2D
class_name Game

@onready var player_spawn : Node2D = %Players
@onready var select_team_menu : Select_Team_Menu = $UserInterface/Select_Team_Menu


signal player_added(player: Player)
signal player_removed(player_id: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game scene ready on peer: ", multiplayer.get_unique_id())
	cleanup_players()

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	if multiplayer.is_server():
		add_player(1)  # Add server's player

	for id in multiplayer.get_peers():
		add_player(id)

	await get_tree().process_frame
	select_team_menu._fetch_player_entries()


func add_player(id: int):
	if not multiplayer.is_server():
		return
	print("Adding player with id: ", id, " on peer: ", multiplayer.get_unique_id())

	var player_name = "Player:" + str(id)
	if player_spawn.has_node(player_name):
		print("Player " + str(id) + " already exists, not spawning again.")
		return

	var new_player = preload("res://scenes/Player/player.tscn").instantiate()
	player_spawn.add_child(new_player)
	new_player.init(id)
	new_player.set_multiplayer_authority(id)
	new_player.add_to_group("players") 

	if multiplayer.is_server():
		M_Sync.spawned_players.append(new_player)
		M_Sync.synchronizer.add_to_group("players")

	player_added.emit(new_player)

func del_player(id: int):
	if not player_spawn.has_node(str(id)):
		return
	player_spawn.get_node(str(id)).queue_free()
	if multiplayer.is_server():
		M_Sync.set_multiplayer_authority(multiplayer.get_unique_id())
		for player in M_Sync.spawned_players:
			if player.player_id == id:
				M_Sync.spawned_players.erase(player)
		#Todo: fix this bugprone code
		player_removed.emit(id)


func cleanup_players():
	for child in player_spawn.get_children():
		child.queue_free()	
	if multiplayer.is_server():
		M_Sync.set_multiplayer_authority(multiplayer.get_unique_id())
		M_Sync.spawned_players.clear()


func get_local_player() -> Player:
	for player in M_Sync.spawned_players:
		if player == M_Sync.synchronizer:
			return null
		if player.player_id == multiplayer.get_unique_id():
			return player
	return null

func start_game():
	if not multiplayer.is_server():
		return
	
	for player in M_Sync.spawned_players:
		if player.get_team() == "Spectator":
			print("Not all players have selected a team. Cannot start the game.")
			return
	
	# Hide the team selection menu
	select_team_menu.hide()
	
	# Spawn tanks for each player
	for player in M_Sync.spawned_players:
		print("Spawning tank for player: ", player.player_id)


	
