extends Control

var time_elapsed: float
var errortween: Tween

func _ready() -> void:
	#start_time = Time.get_unix_time_from_system()
	$EndLabel.visible = false
	Globals.end_game.connect(func(): $EndLabel.visible = true)

func _process(delta: float) -> void:

	# time
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
	$TopLeftUI/Timer/Text.text = str(snapped(time_elapsed, 0.1))
	$TopLeftUI/Health/Text.text = str(Globals.player_health)
	$TopLeftUI/KillCounter/Text.text = str(Globals.total_demons - len(Globals.demons))
	$Panel/ProgressBar/KillCounter/Text.text = str(Globals.motes)


func display_error(errortext: String) -> void:
	var errorlabel = $errors/Error
	errorlabel.text = errortext
	if errortween:
		errortween.kill()
	errortween = get_tree().create_tween()
	errorlabel.modulate = Color("#f00")
	errortween.tween_property(errorlabel, "modulate", Color("#fff"), 0.1)
