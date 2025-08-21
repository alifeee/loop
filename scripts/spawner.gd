class_name Spawner
extends Node2D

# drop spawner
@export var DemonDrops: Node2D
# timer
@export var timer: Timer
@export var ratetimer: Timer
# rate increases
@export var rate_every_s: float = 5
@export var rate_subtract_s: float = 0
@export var rate_multiply: float = 0.96
@export var rate_minimum_s: float = 0.4
# spawn radiuses
@export var ELLIPSE_X_RADIUS: float = 500
@export var ELLIPSE_Y_RADIUS: float = 300
var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	packeddemon = preload("res://scenes/demon.tscn")
	# stop timers on game end
	Globals.gamestate_end.connect(timer.stop)
	
	# rate timer - to increase spawns
	ratetimer.wait_time = rate_every_s
	
	# signals
	timer.start()
	ratetimer.start()
	
	# spawn one now (debugging)
	_on_timer_timeout()

func spawnenemies() -> void:
	for i in range(100):
		var demon = packeddemon.instantiate()
		var distance = rng.randf_range(0.25, 1)
		var spawning_angle = rng.randf_range(0.0, 2*PI)
		demon.position = Vector2(
			distance * ELLIPSE_X_RADIUS * sin(spawning_angle),
			distance * ELLIPSE_Y_RADIUS * cos(spawning_angle)
		)
		demon.modulate.a = 0
		if spawning_angle < PI:
			demon.scale.x = -1
		else:
			demon.scale.x = 1
		demon.DemonDrops = DemonDrops
		Globals.total_demons += 1
		Globals.demons.append(demon)
		add_child(demon)
		demon.slow_appear()

func increase_rate() -> void:
	var new_time = (timer.wait_time - rate_subtract_s) * rate_multiply
	timer.wait_time = max(new_time, rate_minimum_s)

func _on_timer_timeout() -> void:
	var newdemon: Demon = packeddemon.instantiate()
	var spawning_angle = rng.randf_range(0.0, 2*PI)
	newdemon.position = Vector2(
		ELLIPSE_X_RADIUS * sin(spawning_angle),
		ELLIPSE_Y_RADIUS  * cos(spawning_angle)
	)
	newdemon.walk_towards = Vector2(0,0)
	Globals.demons.append(newdemon)
	Globals.total_demons += 1
	add_child(newdemon)
