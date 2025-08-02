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
	
	# current rate
	$CurrentRate.text = str($"../Spawner/SpawnTimer".wait_time)
	
	# next spawn
	$NextSpawn.text = str(snapped($"../Spawner/SpawnTimer".time_left, 0.1))
	
	# current rate timer
	$RateIncrease.text = str(snapped($"../Spawner/RateTimer".time_left, 0.1))
	
	# rate subtract
	$RateSubtract.text = str($"../Spawner".rate_subtract_s)
	
	# rate mult
	$RateMult.text = str($"../Spawner".rate_multiply)
