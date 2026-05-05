extends Node


class_name CharacterStateMachine
@export var player : CharacterBody3D;
@export var current_state : State;
@export var viewmodel : Camera3D;

var states: Array[State] 

func check_if_can_move() -> bool:
	return current_state.can_move

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if(child is State):
			states.append(child)
			child.player = player
			
			#Connect to interrupt signal
			
			#child.connect("interrupt_state", on_state_interrupt_state)
			
		else:
			push_warning("Child " + child.name + " is not a State for CharacterStateMachine!")

			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	if (current_state.next_state != null):
		switch_states(current_state.next_state)
	current_state.state_process(delta)



func switch_states(new_state : State) -> void:
	if(current_state != null):
		current_state.on_exit()
		current_state.next_state = null
		
	current_state = new_state
	
	current_state.on_enter()

func _input(event : InputEvent) -> void:
	current_state.state_input(event)
	
func on_state_interrupt_state(new_state : State) -> void:
	switch_states(new_state)
