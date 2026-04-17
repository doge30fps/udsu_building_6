extends State

class_name AirState

@export var ground_state : State;

func state_process(delta : float) -> void:
	if(player.is_on_floor()):
		next_state = ground_state;
