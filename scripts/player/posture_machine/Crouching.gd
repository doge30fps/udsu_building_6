extends Posture

class_name CrouchingPosture

@export var standing_posture : Posture
@export var posture_machine : CharacterPostureMachine;

func posture_process(delta : float) -> void:
	if player.speed > 2 and !player.is_in_crouch:
		next_posture = standing_posture;
	
