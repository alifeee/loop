extends Control

@export var close_button: Button
@export var shop_button: Button
@export var shop_canvas: CanvasLayer
@export var progress_bar: ProgressBar

func _ready() -> void:
	#start_time = Time.get_unix_time_from_system()
	$EndLabel.visible = false
	
	close_button.disabled = true
	close_button.modulate.a = 0.5
	close_button.focus_mode = Control.FOCUS_NONE
	
	#shop_button.disabled = true
	#shop_button.modulate.a = 0.5
	#shop_button.focus_mode = Control.FOCUS_NONE
	
	Globals.end_game.connect(func(): $EndLabel.visible = true)
	Globals.reset_game.connect(func(): $EndLabel.visible = false)
	Globals.reset_game.connect(func(): $EndLabel.text = "you suck!")
	Globals.start_game.connect(func(): $EndLabel.visible = false)
	
	close_button.pressed.connect(
		func():
			Globals.endgame(true)
			$EndLabel.text = "you s̶u̶c̶k̶ win!"
	)
	shop_button.pressed.connect(
		func():
			if Globals.gamestate == Globals.GAMESTATES.PLAYING:
				Globals.pause()
				if shop_canvas:
					shop_canvas.visible = true
	)
	var close_button: Button = shop_canvas.find_child("CloseButton")
	close_button.pressed.connect(
		func():
			Globals.resume()
			if shop_canvas:
				shop_canvas.visible = false
	)
	
func _process(delta: float) -> void:
	$TopLeftUI/Timer/Text.text = str(snapped(Globals.time_elapsed, 0.1))
	$TopLeftUI/Health/Text.text = str(Globals.player_health)
	$TopLeftUI/KillCounter/Text.text = str(Globals.total_demons - len(Globals.demons))
	$Panel/ProgressBar/KillCounter/Text.text = str(Globals.motes)
	progress_bar.value = Globals.motes
	if Globals.motes >= progress_bar.max_value:
		close_button.disabled = false
		close_button.modulate.a = 1
