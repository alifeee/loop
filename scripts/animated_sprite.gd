extends AnimatedSprite2D

@export var dieondie: bool = false

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	Globals.end_game.connect(pause)
	Globals.spawn_bunch_of_enemies.connect(disappear)

func disappear():
	if not dieondie:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0,0), 3)
