extends Camera2D

signal spawn_loop(v2: Vector2)

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var mouse_position_log = []

func _input(event):
	var normalised_position = event.global_position + self.position

	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				if event.pressed:
					spawn_loop.emit(normalised_position)
