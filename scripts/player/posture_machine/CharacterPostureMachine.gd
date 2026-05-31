extends Node

class_name CharacterPostureMachine
@export var player : CharacterBody3D;
@export var current_posture : Posture;
@export var viewmodel : Camera3D;

var postures: Array[Posture] 

func check_if_can_move() -> bool:
	return current_posture.can_move

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if(child is Posture):
			postures.append(child)
			child.player = player
			#Connect to interrupt signal
			
			#child.connect("interrupt_posture", on_posture_interrupt_posture)
			
		else:
			push_warning("Child " + child.name + " is not a Posture for CharacterPostureMachine!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	if (current_posture.next_posture != null):
		switch_postures(current_posture.next_posture)
	current_posture.posture_process(delta)

func switch_postures(new_posture : Posture) -> void:
	if(current_posture != null):
		current_posture.on_exit()
		current_posture.next_posture = null
		
	current_posture = new_posture
	
	current_posture.on_enter()

func _input(event : InputEvent) -> void:
	current_posture.posture_input(event)
	
func on_posture_interrupt_posture(new_posture : Posture) -> void:
	switch_postures(new_posture)
