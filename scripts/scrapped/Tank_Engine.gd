extends Node
class_name Tank_Engine

@export var engine_force : float = 1000000
@export var engine_force_angular : float = 1000000

var input_break : float
var input_gear : int
var gear : int = 0
var gear_memory : int = 0
var top_gear : int = 5
var reverse_gear : int = -1

var engine_toggle : bool = false

var applied_force : float
var applied_force_angular : float

@onready var tank : Tank = get_parent()


func _input(event):
	if Input.is_action_just_pressed("Engine | Toggle"):
		engine_toggle = !engine_toggle

	if engine_toggle:
		var new_gear_memory = Input.get_axis("Engine | Gear_Down","Engine | Gear_Up")
		if gear_memory == 0:
			gear_memory = new_gear_memory
			if gear_memory == 1:
				gear_up()
			elif gear_memory == -1:
				gear_down()
		elif gear_memory != 0 and new_gear_memory == 0:  
			gear_memory = new_gear_memory
	if engine_toggle:
		input_break = Input.get_axis("Tank | Break_Left","Tank | Break_Right")

func gear_up():
	if gear < top_gear:
		gear += 1

func gear_down():
	if gear > reverse_gear:
		gear -= 1

func move_tank():
	applied_force = engine_force * gear
	tank.apply_force(Vector2(sin(tank.global_rotation), cos(tank.global_rotation)) * applied_force)


func rotate_tank():
	applied_force_angular = engine_force_angular * input_break * gear
	tank.apply_torque(applied_force_angular)

