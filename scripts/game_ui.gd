extends Control

@export var close_button: Button
@export var shop_button: Button
@export var progress_bar: ProgressBar

func _ready() -> void:
	#start_time = Time.get_unix_time_from_system()
	$EndLabel.visible = false
	close_button.disabled = true
	close_button.modulate.a = 0.5
	shop_button.disabled = true
	shop_button.modulate.a = 0.5
	Globals.end_game.connect(func(): $EndLabel.visible = true)
	Globals.reset_game.connect(func(): $EndLabel.visible = false)
	Globals.reset_game.connect(func(): $EndLabel.text = "you suck!")
	close_button.pressed.connect(
		func():
			Globals.endgame()
			$EndLabel.text = "you s̶u̶c̶k̶ win!"
	)
	Globals.start_game.connect(func(): $EndLabel.visible = false)
	
func _process(delta: float) -> void:
	$TopLeftUI/Timer/Text.text = str(snapped(Globals.time_elapsed, 0.1))
	$TopLeftUI/Health/Text.text = str(Globals.player_health)
	$TopLeftUI/KillCounter/Text.text = str(Globals.total_demons - len(Globals.demons))
	$Panel/ProgressBar/KillCounter/Text.text = str(Globals.motes)
	progress_bar.value = Globals.motes
	if Globals.motes >= progress_bar.max_value:
		close_button.disabled = false
		close_button.modulate.a = 1
