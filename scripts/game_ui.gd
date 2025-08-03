extends Control

@export var close_button: Button
@export var shop_button: Button
@export var shop_canvas: CanvasLayer
@export var progress_bar: ProgressBar

# Game ending stuff
@export var game_end_ui: Panel
@export var end_label: Label
@export var time_label: Label
@export var kill_label: Label
@export var mote_label: Label
@export var hat_label: Label

func _ready() -> void:
	#start_time = Time.get_unix_time_from_system()
	game_end_ui.hide()
	$TopLeftUI.visible = true
	$Panel.visible = true
	
	close_button.disabled = true
	close_button.modulate.a = 0.5
	close_button.focus_mode = Control.FOCUS_NONE
	
	#shop_button.disabled = true
	#shop_button.modulate.a = 0.5
	#shop_button.focus_mode = Control.FOCUS_NONE
	
	Globals.end_game.connect(func(): show_game_end_stuff())
	Globals.reset_game.connect(func(): game_end_ui.hide())
	Globals.reset_game.connect(func(): end_label.text = "Overrun!")
	Globals.start_game.connect(func(): game_end_ui.hide())
	
	close_button.pressed.connect(
		func():
			Globals.endgame(true)
			$TopLeftUI.visible = false
			$Panel.visible = false
			end_label.text = "Escaped!"
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
	
	Globals.reset_game.connect(reset)
	
func reset():
	$TopLeftUI.visible = true
	$Panel.visible = true
	
func _process(delta: float) -> void:
	$TopLeftUI/Timer/Text.text = str(snapped(Globals.time_elapsed, 0.1))
	$TopLeftUI/Health/Text.text = str(Globals.player_health)
	$TopLeftUI/KillCounter/Text.text = str(Globals.total_demons - len(Globals.demons))
	$Panel/ProgressBar/KillCounter/Text.text = str(Globals.motes)
	progress_bar.value = Globals.motes
	if Globals.motes >= progress_bar.max_value:
		close_button.disabled = false
		close_button.modulate.a = 1

func show_game_end_stuff():
	game_end_ui.show()
	
	game_end_ui.modulate.a = 0;
	var tween = get_tree().create_tween()
	tween.tween_property(game_end_ui, "modulate:a", 1, 1)
	
	time_label.text = "Time: " + str(snapped(Globals.time_elapsed, 0.1))
	kill_label.text = "x " + str(Globals.kill_count)
	mote_label.text = "x " + str(Globals.lifetime_motes)
	hat_label.text = "x " + str(Globals.hats_owned)

func _on_button_pressed() -> void:
	Globals.reset()
