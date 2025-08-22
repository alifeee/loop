extends Node2D

@export var runes: Sprite2D
@export var fillspeed: float = 2
var fill: float = 0

func _ready() -> void:
	Globals.kill_runes.connect(disappear)
	runes.material.set_shader_parameter("fill", fill)

func _process(delta: float) -> void:
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	fill = move_toward(
		fill,
		Globals.round_progress / float(Globals.TIME_TO_WIN),
		delta * fillspeed
	)
	runes.material.set_shader_parameter("fill", fill)
	if fill >= 1.:
		Globals.runes_full.emit()

func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "modulate:a", 0, 3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
