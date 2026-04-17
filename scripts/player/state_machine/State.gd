extends Node

class_name State

@export var can_move : bool = true

var player : CharacterBody3D
var next_state : State


signal interrupt_state(new_state : State);

func state_process(delta : float) -> void:
	pass

func state_input(event : InputEvent) -> void:
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
