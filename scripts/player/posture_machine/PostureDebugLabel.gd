extends Label

@export var posture_machine : CharacterPostureMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	text = "Posture: " + posture_machine.current_posture.name
