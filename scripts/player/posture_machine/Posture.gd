extends Node

class_name Posture

@export var can_move : bool = true

var player : CharacterBody3D
var next_posture : Posture

signal interrupt_posture(new_posture : Posture);

func posture_process(delta : float) -> void:
	pass

func posture_input(event : InputEvent) -> void:
	pass

func on_enter() -> void:
	pass
	
func on_exit() -> void:
	pass
	
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	pass
