extends Sprite2D

@export var flicker_amplitude: float
@export var flicker_time_min: float
@export var flicker_time_max: float

func _ready() -> void:
	randomly_make_shadow_bigger_and_smaller()

#func _process(delta: float) -> void:
	#scale = Vector2(
		#randf_range(1 - flicker_amplitude, 1 + flicker_amplitude),
		#randf_range(1 - flicker_amplitude, 1 + flicker_amplitude),
	#)
	
func randomly_make_shadow_bigger_and_smaller():
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, 
		"scale", 
		Vector2(
			randf_range(1, 1 + flicker_amplitude),
			randf_range(1, 1 + flicker_amplitude),
		), 
		randf_range(flicker_time_min, flicker_time_max)
	)
	tween.tween_callback(randomly_make_shadow_bigger_and_smaller)
