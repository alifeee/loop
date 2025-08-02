extends Node2D

@export var hide_canvas: CanvasLayer
@export var hide_gameui: CanvasLayer
@export var hide_shopui: CanvasLayer

func _ready():
	Globals.start_game.connect(start)
	Globals.reset_game.connect(reset)
	$Button.pressed.connect(_start_game)

func start():
	hide_canvas.visible = true
	hide_gameui.visible = true
	hide_shopui.visible = false
func reset():
	hide_gameui.visible = false
	hide_canvas.visible = true
	hide_shopui.visible = false

func _start_game():
	Globals.start()
	hide_canvas.visible = false
