extends Sprite2D

@export var stoponlose: bool = false

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

var initial_modulate: Color

var tween: Tween
var deathtween: Tween

func _ready() -> void:
	randomly_make_shadow_bigger_and_smaller()
	Globals.spawn_bunch_of_enemies.connect(stopstuff)
	Globals.reset_game.connect(reset)
	initial_modulate = modulate
	visible = true
	reset()

func reset() -> void:
	if tween:
		tween.kill()
	if deathtween:
		deathtween.kill()
	modulate = initial_modulate

#func _process(delta: float) -> void:
	#scale = Vector2(
		#randf_range(1 - flicker_amplitude, 1 + flicker_amplitude),
		#randf_range(1 - flicker_amplitude, 1 + flicker_amplitude),
	#)

func stopstuff():
	if not stoponlose:
		return
	if tween:
		tween.kill()
	if deathtween:
		deathtween.kill()
	deathtween = get_tree().create_tween()
	deathtween.tween_property(self, "modulate:a", 0, 3)
	
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
