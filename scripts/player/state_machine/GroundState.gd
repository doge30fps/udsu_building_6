extends State

class_name GroundState

@export var air_state : State

func state_process(_delta : float) -> void:
	if(!player.is_on_floor()):
		next_state = air_state
