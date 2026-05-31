extends Node3D

@onready var reach_ray : RayCast3D = $Reach
@onready var viewmodel : Camera3D = $Camera/SubViewportContainer/SubViewport/viewmodel
@onready var camera : Camera3D = $Camera
@export var sub_viewport : SubViewport;
@export var player : CharacterBody3D;
@export var MOUSE_SENS : float = 3.0
@export var CAM_BOB : float = 0.11
@export var bob_enabled : bool = true
@export var smooth : bool = true

var target_rot_x: float = 0.0
var target_rot_y: float = 0.0
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

@onready var feet = $"../Feet"

# СЛОВАРЬ: для каждого типа поверхности свой массив звуков шагов
var step_sounds_map = {
	"wood": [
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_01.ogg"),
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_02.ogg"),
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_03.ogg"),
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_04.ogg"),
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_05.ogg"),
		preload("res://sounds/player/steps/wooden_floor/wooden_floor_06.ogg")
	],
	"concrete": [
		preload("res://sounds/player/steps/concrete/concrete_01.ogg"),
		preload("res://sounds/player/steps/concrete/concrete_02.ogg"),
		preload("res://sounds/player/steps/concrete/concrete_03.ogg"),
		preload("res://sounds/player/steps/concrete/concrete_04.ogg"),
		preload("res://sounds/player/steps/concrete/concrete_05.ogg"),
		preload("res://sounds/player/steps/concrete/concrete_06.ogg")
	]
}
# если поверхность не найдена
var default_step_sounds = step_sounds_map["concrete"]

# Прыжки и приземления. Пока бетонными оставил
@onready var land_sounds = [
	preload("res://sounds/player/steps/concrete/land_concrete_01.ogg"),
	preload("res://sounds/player/steps/concrete/land_concrete_02.ogg"),
	preload("res://sounds/player/steps/concrete/land_concrete_03.ogg"),
	preload("res://sounds/player/steps/concrete/land_concrete_04.ogg"),
	preload("res://sounds/player/steps/concrete/land_concrete_05.ogg")
]
@onready var jump_sounds = [
	preload("res://sounds/player/steps/concrete/jump_concrete_01.ogg"),
	preload("res://sounds/player/steps/concrete/jump_concrete_02.ogg"),
	preload("res://sounds/player/steps/concrete/jump_concrete_03.ogg")
]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sub_viewport.size = DisplayServer.window_get_size();
	
	
func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and smooth==false:
		rotation.x -= event.relative.y * MOUSE_SENS * 0.001
		rotation.x = clamp(rotation.x, -1.5, 1.5)		
		player.rotation.y -= event.relative.x * MOUSE_SENS * 0.001
		player.rotation.y = wrapf(player.rotation.y, 0.0, TAU)
		viewmodel.sway(Vector2(event.relative.x,event.relative.y))
	if event is InputEventMouseMotion and smooth==true:
		target_rot_x -= event.relative.y * MOUSE_SENS * 0.001
		target_rot_x = clamp(target_rot_x, -1.5, 1.5)
		target_rot_y -= event.relative.x * MOUSE_SENS * 0.001
		target_rot_y = wrapf(target_rot_y, 0.0, TAU)   # ← добавить эту строку
		viewmodel.sway(Vector2(event.relative.x, event.relative.y))
		
func _physics_process(delta : float) -> void:
	reach_ray.rotation_degrees = viewmodel.viewmodel_reach_ray.global_rotation_degrees;
	viewmodel.global_position = camera.global_position;
	camera.rotation_degrees = viewmodel.global_rotation_degrees
	
	if smooth:
		rotation.x = lerp(rotation.x, target_rot_x, 15.0 * delta)
		player.rotation.y = lerp_angle(player.rotation.y, target_rot_y, 15.0 * delta)
	else:
		rotation.x = target_rot_x
		player.rotation.y = target_rot_y
		player.rotation.y = wrapf(player.rotation.y, 0.0, TAU)
	
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
				play_random_sound(speed_clamped)    # шаг
				left_played = false
				right_played = true
			if cam_pos.y <= -0.04 and !left_played:
				play_random_sound(speed_clamped)    # шаг
				left_played = true
				right_played = false
		if was_on_floor and !player.is_on_floor():
			play_random_sound(speed_clamped, jump_sounds)   # прыжок
		if player.is_on_floor() and !was_on_floor:
			play_random_sound(speed_clamped, land_sounds)   # приземление
			
		sway_camera(Vector3(player.blend_rotation.z, player.blend_rotation.y, player.blend_rotation.x));
		was_on_floor = player.is_on_floor();
	
func sway_camera(sway_amount : Vector3) -> void:
	camera.global_rotation.z -= sway_amount.z*0.002;

# sounds по умолчанию пустой массив,
# и если он пуст берём звуки из step_sounds_map по текущей поверхности
func play_random_sound(speed : float, sounds : Array = []) -> void:
	# Если массив не передан (т.е. это обычный шаг)
	if sounds.is_empty():
		var surface = player.current_surface
		sounds = step_sounds_map.get(surface, default_step_sounds)
	
	var current = sounds[0]
	feet.stream = current
	feet.play()
	
	if player.is_in_crouch and was_on_floor:
		feet.volume_db = linear_to_db(speed/5)-5
	else:
		feet.volume_db = linear_to_db(speed)-5
	sounds.shuffle()
	sounds.erase(current)
	sounds.push_back(current)
