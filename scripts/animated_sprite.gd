extends AnimatedSprite2D

@export var dieondie: bool = false
@export var animateonwin: bool = false
@export var is_portal: bool = false

var initial_scale: Vector2

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	Globals.end_game.connect(pause)
	Globals.spawn_bunch_of_enemies.connect(disappear)
	Globals.win.connect(_win)
	initial_scale = scale
	Globals.reset_game.connect(reset)
	reset()

func reset() -> void:
	scale = initial_scale
	if is_portal:
		play("summon_portal")

func disappear():
	if not dieondie:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0,0), 3)

func _win ():
	if animateonwin:
		play()
	if is_portal:
		play("summon_portal")
		await get_tree().create_timer(1.5).timeout
		play("open_portal")
		await get_tree().create_timer(1.0).timeout
		play("portal")	
