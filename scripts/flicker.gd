extends Sprite2D
## flicker sprites :]
## used for shadow, portal glows, and portal runes (and maybe more!)

# Size Flikering
@export var keep_aspect_ratio: bool
@export var base_size: float
@export var flicker_amplitude: float

# Alpha Flikering
@export var alpha_flickering: bool
@export var base_alpha: float
@export var alpha_amplitude: float

@export var flicker_time_min: float
@export var flicker_time_max: float

var tween: Tween
var deathtween: Tween

func _ready() -> void:
	randomly_make_shadow_bigger_and_smaller()
	
func randomly_make_shadow_bigger_and_smaller():
	tween = get_tree().create_tween()
	
	var tween_time = randf_range(flicker_time_min, flicker_time_max)
	
	var random_vector2
	if keep_aspect_ratio:
		var random_value = randf_range(base_size - flicker_amplitude, base_size + flicker_amplitude)
		random_vector2 = Vector2(
			random_value,
			random_value,
		)
	else:
		random_vector2 = Vector2(
			randf_range(base_size - flicker_amplitude, base_size + flicker_amplitude),
			randf_range(base_size - flicker_amplitude, base_size + flicker_amplitude),
		)
	tween.tween_property(
		self, 
		"scale", 
		random_vector2, 
		tween_time
	)
	if alpha_flickering:
		tween.parallel().tween_property(
			self, 
			"self_modulate:a", 
			randf_range(base_alpha - alpha_amplitude, base_alpha + alpha_amplitude), 
			tween_time
		)
	tween.tween_callback(randomly_make_shadow_bigger_and_smaller)
