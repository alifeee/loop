extends Node2D

@export var screenshake_amplitude: float
@export var screenshake_duration_time: float
@export var screenshake_duration_left: float

func _ready() -> void:
	Globals.player_hit.connect(screenshake)
	
func _process(delta: float) -> void:
	if screenshake_duration_left > 0:
		get_tree().root.global_canvas_transform.origin = Vector2(
			randf_range(-screenshake_amplitude, screenshake_amplitude), 
			randf_range(-screenshake_amplitude, screenshake_amplitude)
		)
		screenshake_duration_left -= delta
	else:
		get_tree().root.global_canvas_transform.origin = Vector2.ZERO 
	
func screenshake(wizard_number: int):
	screenshake_duration_left = screenshake_duration_time
	print("ShakeScreen")
