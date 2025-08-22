class_name Spawner
extends Node2D

# where to put enemies
@export var demoncontainer: Node2D
# timer
@export var timer: Timer
@export var ratetimer: Timer
# spawn radiuses
@export var ELLIPSE_X_RADIUS: float = 500
@export var ELLIPSE_Y_RADIUS: float = 300
var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	for demon in demoncontainer.get_children().duplicate():
		demon.queue_free()
	packeddemon = preload("res://scenes/demon.tscn")
	# stop timers on game end
	Globals.spawn_loads_of_enemies.connect(spawn_loads_of_enemies)
	
	timer.wait_time = Globals.initial_spawn_timeout
	ratetimer.wait_time = Globals.rate_increase_timeout
	
	# signals
	timer.start()
	ratetimer.start()
	
	# spawn one now (debugging)
	#if OS.is_debug_build():
		#_on_timer_timeout()

func _process(delta: float) -> void:
	if timer.paused and Globals.gamestate == Globals.GAMESTATES.PLAYING:
		timer.paused = false
		ratetimer.paused = false
	if (not timer.paused) and Globals.gamestate != Globals.GAMESTATES.PLAYING:
		timer.paused = true
		ratetimer.paused = true

func spawn_loads_of_enemies() -> void:
	for i in range(100):
		var demon: Demon = packeddemon.instantiate()
		var distance = rng.randf_range(0.25, 1)
		var spawning_angle = rng.randf_range(0.0, 2*PI)
		demon.position = Vector2(
			distance * ELLIPSE_X_RADIUS * sin(spawning_angle),
			distance * ELLIPSE_Y_RADIUS * cos(spawning_angle)
		)
		demon.modulate.a = 0
		demon.do_slow_appear = true
		if spawning_angle < PI:
			demon.sprite.scale.x = -1
		else:
			demon.sprite.scale.x = 1
		Globals.demons.append(demon)
		demoncontainer.call_deferred("add_child", demon)

func increase_rate() -> void:
	var new_time = (
		timer.wait_time - Globals.rate_increase_subtract
	) * Globals.rate_increase_multiply
	timer.wait_time = max(new_time, Globals.minimum_spawn_timeout)

func _on_timer_timeout() -> void:
	var newdemon: Demon = packeddemon.instantiate()
	var spawning_angle = rng.randf_range(0.0, 2*PI)
	newdemon.position = Vector2(
		ELLIPSE_X_RADIUS * sin(spawning_angle),
		ELLIPSE_Y_RADIUS  * cos(spawning_angle)
	)
	newdemon.walk_towards = Vector2(0,0)
	Globals.demons.append(newdemon)
	Globals.total_demons_spawned += 1
	demoncontainer.add_child(newdemon)
