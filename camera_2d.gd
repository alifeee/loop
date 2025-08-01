extends Camera2D

# trimmed down version of https://github.com/adamviola/simple-free-look-camera
signal spawnThing(v2: Vector2, mob: PackedScene)


# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
@export var mob_scene: PackedScene

func _input(event):
	var normalised_position = - self.get_screen_center_position() + event.position
	
	# Receives mouse motion
	if event is InputEventMouseMotion:
		if _mouse_position != event.relative:
			print("CLICKING STOPP:", normalised_position)
			_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				if event.pressed:
					var m = mob_scene.instantiate()
					
