extends StaticBody3D

var toggle = false
var interactable = true
@export var animation_player: AnimationPlayer

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("close")
		if toggle == true:
			animation_player.play("open")
		interactable = true
