extends AnimatedSprite2D

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
 
