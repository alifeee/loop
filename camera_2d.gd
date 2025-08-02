extends Camera2D

signal spawnThing(v2: Vector2, mob: Node)
signal damageEnemy(pos: Vector2, radius: int)

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
@export var mob_scene: PackedScene


var mouse_position_log = []

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
					spawnThing.emit(normalised_position, m)
