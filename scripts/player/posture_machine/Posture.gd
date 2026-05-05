extends Node

class_name Posture

@export var can_move : bool = true

var player : CharacterBody3D
var next_posture : Posture


func posture_process(_delta : float) -> void:
	pass

func posture_input(_event : InputEvent) -> void:
	pass

func on_enter() -> void:
	pass
	
func on_exit() -> void:
	pass
	
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass
