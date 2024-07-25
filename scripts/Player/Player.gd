extends Node2D
class_name Player


@export var tank_name : String = "Tank"
@export var kills : int = 0
@export var player_id : int
@export var player_team : int = 0  # 0 for spectator, 1 for German, 2 for Soviet

signal team_changed(new_team: String)

func _enter_tree():
	add_to_group("players")
	print("Player ", name, " added to 'players' group")

	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	print("Player ", name, " ready on peer ", multiplayer.get_unique_id())
	
func init(id: int):
	player_id = id

@rpc("any_peer", "call_local")
func set_team(team: String):
	match team:
		"German":
			player_team = 1
		"Soviet":
			player_team = 2
		"Spectator":
			player_team = 0
    
	team_changed.emit(team)

func get_team() -> String:
	match player_team:
		1:
			return "German"
		2:
			return "Soviet"
		_:
			return "Spectator"