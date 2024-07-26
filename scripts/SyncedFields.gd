extends Node
class_name SyncedFields

var spawned_players : Array[Player] = []
var player_entries : Array[PanelContainer] = []

@onready var synchronizer : MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready():
	# Ensure the MultiplayerSynchronizer node is added as a child
	if !has_node("MultiplayerSynchronizer"):
		var sync = MultiplayerSynchronizer.new()
		add_child(sync)
		synchronizer = sync

	# Configure which properties to replicate
	var config = SceneReplicationConfig.new()
	config.add_property("spawned_players")
	config.add_property("player_entries")
	synchronizer.set_replication_config(config)
	
	# Set the synchronizer to run on both server and clients
	synchronizer.set_multiplayer_authority(1)  # Set server as authority
	
	# Enable processing
	set_process(true)

func _process(_delta):
	# Ensure synchronization happens every frame
	if multiplayer.is_server():
		synchronizer.replication_interval = 0.0  # Update every frame
	else:
		synchronizer.replication_interval = 0.1  # Update 10 times per second on clients