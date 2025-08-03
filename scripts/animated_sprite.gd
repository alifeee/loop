extends AnimatedSprite2D

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	Globals.end_game.connect(_win)

func _win ():
	play("summon_portal")
	await get_tree().create_timer(1.5).timeout
	play("open_portal")
	await get_tree().create_timer(1.0).timeout
	play("portal")	
