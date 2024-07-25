extends PanelContainer
class_name Player_Entry


@onready var name_label : Label = %Name_Label
@onready var kills_label : Label = %Kills_Label
@onready var tank_image : TextureRect = %TankImage
@onready var kills_score_label : Label = %KillScore_Label

var player_ref : Player

func init(_player_ref : Player):
	player_ref = _player_ref

func _ready():
	if not player_ref:
		push_error("Player_Entry initialized without player reference")
		return
	
	call_deferred("update_ui")

func update_ui():
	if player_ref:
		name_label.text = player_ref.tank_name
		kills_score_label.text = str(player_ref.kills)
		
func set_color(color : Color):
	name_label.modulate = color
	kills_label.modulate = color
	kills_score_label.modulate = color
	tank_image.modulate = color
