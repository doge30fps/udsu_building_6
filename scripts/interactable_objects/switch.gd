extends StaticBody3D

var toggle = false
var interactable = true
@onready var animation_player_switch: AnimationPlayer = $AnimationPlayer
@export var animation_player_omnilight: AnimationPlayer
@export var lamp_material: StandardMaterial3D

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player_switch.play("close")
			animation_player_omnilight.play("close")
		if toggle == true:
			animation_player_switch.play("open")
			animation_player_omnilight.play("open")
		interactable = true
