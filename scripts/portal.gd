extends Node2D

@export var timer: Timer
@export var ratetimer: Timer
@export var rate_every_s: float = 5
@export var rate_subtract_s: float = 0
@export var rate_multiply: float = 0.96
@export var rate_minimum_s: float = 0.4
var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	packeddemon = preload("res://scenes/demon.tscn")
	_on_timer_timeout()
	Globals.pause_game.connect(stop_timer)
	Globals.end_game.connect(stop_timer)
	Globals.resume_game.connect(start_timer)
	# rate
	ratetimer.wait_time = rate_every_s
	ratetimer.stop()
	ratetimer.start()
	ratetimer.timeout.connect(increase_rate)

func increase_rate() -> void:
	var new_time = (timer.wait_time - rate_subtract_s) * rate_multiply
	timer.wait_time = max(new_time, rate_minimum_s)

func stop_timer() -> void:
	timer.paused = true
	ratetimer.paused = true
func start_timer() -> void:
	timer.paused = false
	ratetimer.paused = false   

func _on_timer_timeout() -> void:
	var newdemon: Demon = packeddemon.instantiate()
	var spawning_angle = rng.randf_range(0.0, 2*PI)
	var spawning_distance = 320 # px
	newdemon.position = Vector2(
		spawning_distance * sin(spawning_angle),
		spawning_distance * cos(spawning_angle)
	)
	newdemon.walk_angle = spawning_angle - PI
	Globals.demons.append(newdemon)
	Globals.total_demons += 1
	add_child(newdemon)
