extends RayCast3D

@onready var interact_label : Label = $interact_label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$interact_label.visible = false
	if is_colliding():
		var hitobj = get_collider()
		if hitobj.has_method("interact"):
			$interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				hitobj.interact()
