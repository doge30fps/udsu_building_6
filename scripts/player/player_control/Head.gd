extends Node3D

@onready var reach_ray : RayCast3D = $Reach
@onready var viewmodel : Camera3D = $Camera/SubViewportContainer/SubViewport/viewmodel
@onready var camera : Camera3D = $Camera
@export var sub_viewport : SubViewport;
@export var player : CharacterBody3D;

@export var MOUSE_SENS : float = 3.0

@export var CAM_BOB : float = 0.11
@export var bob_enabled : bool = true

var step_speed : float;
var t : float = 0.0
var cam_pos : Vector2
var grounded : float;
var speed_clamped : float;
var tcam_pos : Vector2;
var horizontal_velocity : Vector2;
var left_played : bool = false
var right_played : bool = false
var was_on_floor : bool = false




@onready var feet = player.get_node("Feet")
@onready var feet_sounds = [
	preload("res://player/Sounds/steps/concrete_01.ogg"),
	preload("res://player/Sounds/steps/concrete_02.ogg"),
	preload("res://player/Sounds/steps/concrete_03.ogg"),
	preload("res://player/Sounds/steps/concrete_04.ogg"),
	preload("res://player/Sounds/steps/concrete_05.ogg"),
	preload("res://player/Sounds/steps/concrete_06.ogg")
]
@onready var land_sounds = [
	preload("res://player/Sounds/steps/land_concrete_01.ogg"),
	preload("res://player/Sounds/steps/land_concrete_02.ogg"),
	preload("res://player/Sounds/steps/land_concrete_03.ogg"),
	preload("res://player/Sounds/steps/land_concrete_04.ogg"),
	preload("res://player/Sounds/steps/land_concrete_05.ogg")
]
@onready var jump_sounds = [
	preload("res://player/Sounds/steps/jump_concrete_01.ogg"),
	preload("res://player/Sounds/steps/jump_concrete_02.ogg"),
	preload("res://player/Sounds/steps/jump_concrete_03.ogg")
]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sub_viewport.size = DisplayServer.window_get_size();
	
	
func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * MOUSE_SENS * 0.001
		rotation.x = clamp(rotation.x, -1.5, 1.5)		
		player.rotation.y -= event.relative.x * MOUSE_SENS * 0.001
		player.rotation.y = wrapf(player.rotation.y, 0.0, TAU)
		viewmodel.sway(Vector2(event.relative.x,event.relative.y))
		
func _physics_process(delta : float) -> void:
	reach_ray.rotation_degrees = viewmodel.viewmodel_reach_ray.global_rotation_degrees;
	viewmodel.global_position = camera.global_position;
	camera.rotation_degrees = viewmodel.global_rotation_degrees
	
	step_speed = player.step_speed;
	
	if step_speed != 0:
		grounded = float(player.is_on_floor())
		horizontal_velocity = Vector2(player.velocity.x, player.velocity.z)
		speed_clamped = remap(horizontal_velocity.length(), 0.0, player.speed, 0.0, 1.0)
		t += delta * step_speed * speed_clamped * grounded
		tcam_pos = Vector2(sin(t) * CAM_BOB, cos(t * 0.5) * CAM_BOB)
		if speed_clamped <= 0.1:
			t = 0.0
			tcam_pos = Vector2.ZERO
		cam_pos = lerp(cam_pos, tcam_pos, delta * 5)
		cam_pos = lerp(cam_pos, tcam_pos, delta * 5)
		camera.transform.origin.x = cam_pos.y * float(bob_enabled)
		camera.transform.origin.y = cam_pos.x * float(bob_enabled)
	
		if player.is_on_floor():
			if cam_pos.y >= 0.04 and !right_played:
				play_random_sound(speed_clamped)
				left_played = false
				right_played = true
			if cam_pos.y <= -0.04 and !left_played:
				play_random_sound(speed_clamped)
				left_played = true
				right_played = false
		if was_on_floor and !player.is_on_floor():
			play_random_sound(speed_clamped, jump_sounds)
		if player.is_on_floor() and !was_on_floor:
			play_random_sound(speed_clamped, land_sounds)
			
		sway_camera(Vector3(player.blend_govno.z, player.blend_govno.y, player.blend_govno.x));
		was_on_floor = player.is_on_floor();
	
func sway_camera(sway_amount : Vector3) -> void:
	camera.global_rotation.z -= sway_amount.z*0.002;

func play_random_sound(speed : float, sounds : Array = feet_sounds) -> void:
	var current = sounds[0]
	feet.stream = current
	feet.play()
	
	if player.is_in_crouch and was_on_floor:
		feet.volume_db = linear_to_db(speed/5)
	else:
		feet.volume_db = linear_to_db(speed)
	sounds.shuffle()
	sounds.erase(current)
	sounds.push_back(current)
