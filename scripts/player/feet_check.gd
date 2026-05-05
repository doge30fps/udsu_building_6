extends RayCast3D

# Этот сигнал будет оповещать игрока о том, что поверхность под ним изменилась
signal surface_changed(surface_name: String)

# Предыдущий тип поверхности, чтобы не спамить сигналами при каждом кадре
var last_surface: String = ""

func _physics_process(_delta):
	# Проверяем, есть ли коллизия у луча
	if is_colliding():
		# Получаем объект, в который упёрся луч
		var collider = get_collider()
		# Пытаемся прочитать метаданные "surface_type" у этого объекта
		if collider.has_meta("surface_type"):
			var current_surface = collider.get_meta("surface_type")
			# Если тип поверхности изменился, отправляем сигнал
			if current_surface != last_surface:
				last_surface = current_surface
				surface_changed.emit(current_surface)
			#print_debug("found meta_surface: ", current_surface)
		else:
			# Если у объекта нет метаданных, можно отправить сигнал о поверхности по умолчанию
			if last_surface != "unknown":
				last_surface = "unknown"
				surface_changed.emit("unknown")
			#print_debug("unknown meta_surface!")
