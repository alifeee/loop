extends Node2D

func _ready():
	Globals.reset_game.connect(func(): visible = true)
	$Button.pressed.connect(_start_game)
	
func _start_game():
	Globals.start()
	Globals.gamestate = Globals.GAMESTATES.PLAYING
	visible = false
