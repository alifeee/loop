extends Node2D
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	PAUSED,
	WIN_SCREEN
}
func _ready():
	$Button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	var game_scene = preload("res://scenes/main.tscn")  # Change to your actual game scene path
	get_tree().change_scene_to_packed(game_scene)
	Globals.gamestate = GAMESTATES.PLAYING
