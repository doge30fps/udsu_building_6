extends StaticBody3D # НАСЛЕДОВАНИЕ

var toggle = false # Переключатель
var interactable = true # Флаг для взаимодействия
@export var animation_player: AnimationPlayer # Ссылка на плеер анимации

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("close") # Вызываем анимацию "закрыть"
		if toggle == true:
			animation_player.play("open") # Вызываем анимацию "закрыть"
		interactable = true
