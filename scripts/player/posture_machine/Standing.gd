extends Posture

class_name StandingPosture

@export var crouching_posture : Posture
@export var posture_machine : CharacterPostureMachine;

func posture_process(delta : float) -> void:
	if player.speed < 4 and player.is_in_crouch:
		next_posture = crouching_posture;
	
