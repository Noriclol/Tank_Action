extends RigidBody2D
class_name Tank

@export var tank_data : TankData

@onready var body : Sprite2D = $Body
@onready var turret : Sprite2D = $Turret
@onready var bullet_spawn : Node2D = $Turret/Node2D
@onready var turret_fire_anim : AnimatedSprite2D = $Turret/Node2D/AnimatedSprite2D
@onready var collision : CollisionShape2D = $CollisionShape2D

func _enter_tree():
	mass = tank_data.tank_weight

func handle_tank_input():

	var tank_thrust = Input.get_axis("Tank | Forward", "Tank | Backward")
	var tank_rotation = Input.get_axis("Tank | RotateLeft", "Tank | RotateRight")
	var turret_rotation = Input.get_axis("Turret | RotateLeft", "Turret | RotateRight")
	var turret_fire = Input.is_action_just_pressed("Turret | Fire")

	if tank_thrust != 0:
		move_tank(tank_thrust)

	if tank_rotation != 0:
		rotate_tank(tank_rotation)

	if turret_rotation != 0:
		rotate_turret(turret_rotation)
	
	if turret_fire:
		fire_gun()
		turret_fire = false


func move_tank(_tank_thrust : float):
	if not is_multiplayer_authority(): return
	# Move the tank
	var thrust = Vector2.DOWN.rotated(rotation) * tank_data.tank_thrust_force * _tank_thrust
	print("thrust: ", thrust)
	apply_central_force(thrust)


func rotate_tank(_tank_rotation : float):
	if not is_multiplayer_authority(): return
	# Rotate the tank
	apply_torque(tank_data.tank_rotation_force * _tank_rotation)
	#angular_velocity = tank_data.tank_rotation_speed * get_parent().input.tank_rotation


func rotate_turret(_turret_rotation : float):
	if not is_multiplayer_authority(): return
	# Rotate the turret
	turret.rotation += tank_data.turret_rotation_speed * _turret_rotation


func fire_gun():
	# Fire the gun
	if not is_multiplayer_authority(): return

	var bullet = tank_data.bullet_instance.instantiate() as RigidBody2D
	get_parent().call_deferred("add_child",bullet)
	bullet.global_position = bullet_spawn.global_position
	bullet.global_rotation = bullet_spawn.global_rotation
	bullet.linear_velocity = Vector2.UP.rotated(bullet.global_rotation) * tank_data.bullet_speed
	turret_fire_anim.play("Fire")


