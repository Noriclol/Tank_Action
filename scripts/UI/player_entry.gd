extends PanelContainer
class_name Player_Entry

var data : PlayerData

@onready var name_label : Label = %Name_Label
@onready var kills_label : Label = %Kills_Label
@onready var tank_image : TextureRect = %TankImage
@onready var kills_score_label : Label = %KillScore_Label


func _init(data: PlayerData):
	self.data = data
	name_label.text = data.custom_tank_name
	kills_score_label.text = str(data.kills)


func _ready():
	set_multiplayer_authority(data.player_id)
	if is_multiplayer_authority():
		pass


func set_color(color : Color):
	name_label.modulate = color
	kills_label.modulate = color
	kills_score_label.modulate = color
	tank_image.modulate = color