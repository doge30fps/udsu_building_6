extends CharacterBody3D

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

# NORMAL SPEED.
@export var normal_speed : float = 3;
# SPRINT/RUNING SPEED.
@export var sprint_speed : float = 4;
@export var crouch_speed : float = 1.0;
# accel_in_air STANDS FOR ACCELERATION IN HANPPENING IN AIR. 
# accel_nomal STANDS FOR ACCELERATION IN NOT HANPPENING IN AIR BUT INSTEAD ON GROUND.
@export var accel_nomal : float = 5.5
@export var accel_in_air : float = 0.5
@export var step_speed_normal : float = 9.5;
# THESE CONSTANTS DEFINE TWO ACCELERATION VALUES:
# THESE VALUES CONTROL HOW QUICKLY THE player SPEEDS UP AND SLOWS DOWN IN DIFFERENT CONTEXTS.
# accel_nomal FOR WHEN THE player IS ON THE GROUND, AND accel_in_air FOR WHEN THE player IS IN THE AIR. 
# ACCEL IS ABOUT THE CURRENT ACCELERATION.
@onready var accel : float = accel_nomal
@export var jump_velocity : float = 6.5 #NO NEED TO SET JUMP VALUE BECAUSE THE CROUCH FUNCTIONS DOES IT'S VALUE Changing.
var speed : float;
var step_speed : float;
# LOWEST HEIGHT AND MAXIMUM.
@export var normal_height : float = 1.8
@export var crouch_height : float = 1.3
# LOWEST HEIGHT AND MAXIMUM TRANSITION SPEED OF CROUCHING.!!!!!!
@export var crouching_speed : float = 1


var input_dir : Vector2
var speed_clamped : float;
var air_time : float = 0.0
var direction : Vector3 = Vector3.ZERO
var is_forward_moving  : bool = false
var is_in_crouch : bool = false;
var is_sprinting : bool = false;
var blend_govno : Vector3;

@export var player_capsule_top : CollisionShape3D
@export var player_capsule_down : CollisionShape3D
@export var head_check : RayCast3D
@export var head : Node3D;
@export var windrush_sound : AudioStreamPlayer;
@export var jump_sound : AudioStreamPlayer;

const EYES_HEAD_DISTANCE : float = 0.12;
@export var BONUS_GRAVITY : float = 3.0


func _physics_process(delta : float) -> void:
	CROUCH(delta);
	
	direction = Vector3.ZERO;
	
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if input_dir.y < 0.0:
		is_forward_moving = true
	else:
		is_forward_moving = false
		
	direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if !is_on_floor():
		accel = accel_in_air
		air_time += delta
		velocity.y -= (GRAVITY + GRAVITY * air_time * BONUS_GRAVITY) * delta
	else:
		accel = accel_nomal
		air_time = 0.0
	
	is_sprinting = false; #
	if Input.is_action_pressed("move_run") and is_forward_moving and !is_in_crouch:
		speed = sprint_speed
		step_speed = (sprint_speed / normal_speed) * step_speed_normal;
		is_sprinting = true; #
		
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor() and !is_in_crouch:
		velocity.y = jump_velocity
		jump_sound.play()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	blend_govno = velocity.rotated(Vector3.UP, -global_rotation.y)
	
	move_and_slide()
	handle_rush()
	handle_bounds()
	

func CROUCH(delta : float) -> void:
	var colliding : bool = false
	if head_check.is_colliding():
		colliding = true
		print_debug("Коллизия: ", colliding)
		
	if Input.is_action_pressed("move_crouch"):
		speed = crouch_speed
		step_speed = (crouch_speed / normal_speed) * step_speed_normal;
		is_in_crouch = true;
		player_capsule_top.position.y -= crouching_speed * delta
		head.position.y -= crouching_speed * delta

	elif not colliding:
		# IT WILL INCREASE THE SIZE OF THE CAPSULE BY THE CROUCHING SPEED AND RESETS THE JUMP VALUE.
		speed = normal_speed
		step_speed = step_speed_normal;
		player_capsule_top.position.y += crouching_speed * delta
		head.position.y += crouching_speed * delta
		is_in_crouch = false;
		
	player_capsule_top.position.y = clamp(player_capsule_top.position.y, crouch_height/2, normal_height-crouch_height/2)
	head.position.y = clamp(head.position.y, crouch_height - EYES_HEAD_DISTANCE, normal_height - EYES_HEAD_DISTANCE)
	
func handle_rush() -> void:
	speed_clamped = remap(pow(velocity.length(), 2), 0.0, speed * 250.0, 0.0, 1.0)
	windrush_sound.volume_db = linear_to_db(speed_clamped)
	windrush_sound.volume_db = clamp(windrush_sound.volume_db, -50, 5)

func handle_bounds() -> void:
	if global_transform.origin.y <= -100.0:
		global_transform.origin = Vector3.ONE
