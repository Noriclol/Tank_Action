extends Control
class_name Select_Team_Menu

@onready var g_team_container : VBoxContainer = %G_Team_Roster
@onready var s_team_container : VBoxContainer = %S_Team_Roster
@onready var spectator_container : VBoxContainer = %Spectator_Roster

@onready var player_entry_scene : PackedScene = preload("res://scenes/UI/player_entry.tscn")

# can add this line to the top of the script to get the Game node
#@export var gamescene : Game

func _ready():
	print("Select_Team_Menu ready")
	var game_node = get_parent().get_parent()
	if game_node is Game:
		print("Game node found, connecting signals")
		game_node.player_added.connect(add_player_entry)
		game_node.player_removed.connect(remove_player_entry)
	else:
		push_error("Parent node is not a Game node")


func _fetch_player_entries():
	var players = get_tree().get_nodes_in_group("players")
	print("Number of existing players locally: ", players.size())
	for player in players:
		print("Existing player: ", player.name, " (ID: ", player.player_id, ")")
		add_player_entry(player)



func add_player_entry(player: Player):
	print("Adding player entry for player: ", player.player_id)

	for entry in M_Sync.player_entries:
		if entry.player_ref and entry.player_ref.player_id == player.player_id:
			print("Player entry already exists for player: ", player.player_id)
			return

	if not player_entry_scene:
		push_error("player_entry_scene is null")
		return

	var entry = player_entry_scene.instantiate()
	if not entry:
		push_error("Failed to instantiate player_entry_scene")
		return

	if not entry is Player_Entry:
		push_error("Instantiated scene is not a Player_Entry")
		return

	entry.init(player)

	M_Sync.player_entries.append(entry)
	spectator_container.add_child(entry)
	print("Player entry added to spectator container for player: ", player.player_id)

func remove_player_entry(player_id: int):
	for i in range(M_Sync.player_entries.size()):
		var entry = M_Sync.player_entries[i]
		if entry.player_ref and entry.player_ref.player_id == player_id:
			entry.queue_free()
			M_Sync.player_entries.remove_at(i)
			break
	
func move_player_to_team(player: Player, team: String):
	var entry = null
	for e in M_Sync.player_entries:
		if e.player_ref and e.player_ref.player_id == player.player_id:
			entry = e
			break
	
	if not entry:
		print("Player entry not found for player: ", player.player_id)
		return
	
	var target_container: VBoxContainer
	var team_color: Color
	
	match team:
		"German":
			target_container = g_team_container
			team_color = Color.DARK_GREEN
			player.player_team = 1
		"Soviet":
			target_container = s_team_container
			team_color = Color.DARK_RED
			player.player_team = 2
		"Spectator":
			target_container = spectator_container
			team_color = Color.WHITE
			player.player_team = 0
		_:
			print("Invalid team: ", team)
			return
	
	if entry.get_parent() != target_container:
		entry.reparent(target_container)
		entry.set_color(team_color)
		
		# Update the entry in M_Sync.player_entries
		var index = M_Sync.player_entries.find(entry)
		if index != -1:
			M_Sync.player_entries[index] = entry
	
	# Call an RPC to sync the team change across the network
	player.rpc("set_team", team)

func _on_german_button_pressed():
	var local_player = get_parent().get_parent().get_local_player()
	move_player_to_team(local_player, "German")


func _on_soviet_button_pressed():
	var local_player = get_parent().get_parent().get_local_player()
	move_player_to_team(local_player, "Soviet")


func _on_spectator_button_pressed():
	var local_player = get_parent().get_parent().get_local_player()
	move_player_to_team(local_player, "Spectator")
