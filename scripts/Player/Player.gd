extends Node2D
class_name Player


@export var tank_name : String = "Tank"
@export var kills : int = 0
@export var player_id : int
@export var player_team : int


func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	print("Player ", name, " ready on peer ", multiplayer.get_unique_id())
	# if not has_node("MultiplayerSynchronizer"):
	# 	push_error("MultiplayerSynchronizer not found for player ", name)
	# else:
	# 	print("MultiplayerSynchronizer found for player ", name)