extends CanvasLayer

var errortween: Tween

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# health
	$stats/Health.text = str(Globals.player_health)
	
	# time

	# enemies total
	$stats/TotalEnemies.text = str(Globals.total_demons)
	
	# enemies now
	$stats/CurrentEnemies.text = str(len(Globals.demons))
	
	# current rate
	$stats/CurrentRate.text = str($"../Spawner/SpawnTimer".wait_time)
	
	# next spawn
	$stats/NextSpawn.text = str(snapped($"../Spawner/SpawnTimer".time_left, 0.1))
	
	# current rate timer
	$stats/RateIncrease.text = str(snapped($"../Spawner/RateTimer".time_left, 0.1))
	
	# rate subtract
	$stats/RateSubtract.text = str($"../Spawner".rate_subtract_s)
	
	# rate mult
	$stats/RateMult.text = str($"../Spawner".rate_multiply)
	
	# loop validity
	$stats/LoopValid.text = str($"..".is_valid)
	
	# game state
	$stats/GameState.text = str(Globals.gamestate)

func display_error(errortext: String) -> void:
	var errorlabel = $errors/Error
	errorlabel.text = errortext
	if errortween:
		errortween.kill()
	errortween = get_tree().create_tween()
	errorlabel.modulate = Color("#f00")
	errortween.tween_property(errorlabel, "modulate", Color("#fff"), 0.1)
