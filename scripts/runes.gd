extends Node2D

@export var runes: Sprite2D
@export var fillspeed: float = 0.05
var fill: float = 0

func _ready() -> void:
	Globals.kill_runes.connect(disappear)
	runes.material.set_shader_parameter("fill", fill)

func _process(delta: float) -> void:
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	fill = lerpf(
		fill,
		Globals.kill_count / float(Globals.KILLS_TO_WIN),
		fillspeed * delta,
	)
	runes.material.set_shader_parameter("fill", fill)
	if fill >= 1.:
		Globals.runes_full.emit()

func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "modulate:a", 0, 3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
