extends Control

var time_elapsed: float
var errortween: Tween
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
	Globals.reset_game.connect(func(): time_elapsed = 0)
	Globals.reset_game.connect(func(): $EndLabel.visible = false)
	Globals.reset_game.connect(func(): $EndLabel.text = "you suck!")
	close_button.pressed.connect(
		func():
			Globals.endgame()
			$EndLabel.text = "you s̶u̶c̶k̶ win!"
	)
	
func _process(delta: float) -> void:
	# time
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
	$TopLeftUI/Timer/Text.text = str(snapped(time_elapsed, 0.1))
	$TopLeftUI/Health/Text.text = str(Globals.player_health)
	$TopLeftUI/KillCounter/Text.text = str(Globals.total_demons - len(Globals.demons))
	$Panel/ProgressBar/KillCounter/Text.text = str(Globals.motes)
	progress_bar.value = Globals.motes
	if Globals.motes >= progress_bar.max_value:
		close_button.disabled = false
		close_button.modulate.a = 1


func display_error(errortext: String) -> void:
	var errorlabel = $errors/Error
	errorlabel.text = errortext
	if errortween:
		errortween.kill()
	errortween = get_tree().create_tween()
	errorlabel.modulate = Color("#f00")
	errortween.tween_property(errorlabel, "modulate", Color("#fff"), 0.1)
