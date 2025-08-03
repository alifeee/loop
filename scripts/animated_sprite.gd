extends AnimatedSprite2D

@export var dieondie: bool = false
@export var animateonwin: bool = false

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	Globals.end_game.connect(pause)
	Globals.spawn_bunch_of_enemies.connect(disappear)
	Globals.win.connect(_win)

func disappear():
	if not dieondie:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0,0), 3)

func _win ():
	if animateonwin:
		play()
	play("summon_portal")
	await get_tree().create_timer(1.5).timeout
	play("open_portal")
	await get_tree().create_timer(1.0).timeout
	play("portal")	
