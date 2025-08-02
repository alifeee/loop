extends Node2D

@export var hide_canvas: CanvasLayer

func _ready():
	Globals.reset_game.connect(func(): hide_canvas.visible = true)
	Globals.start_game.connect(func(): hide_canvas.visible = true)
	$Button.pressed.connect(_start_game)
	
func _start_game():
	Globals.start()
	hide_canvas.visible = false
