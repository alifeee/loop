extends CanvasLayer

var time_elapsed: float

#func _ready() -> void:
	#start_time = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	# time
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
	$TimeLabel.text = str(snapped(time_elapsed, 0.1))

	# enemies total
	$TotalEnemies.text = str(Globals.total_demons)
	
	# enemies now
	$CurrentEnemies.text = str(len(Globals.demons))
