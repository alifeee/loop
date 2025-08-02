extends Node2D

# timer
@export var timer: Timer
var timer_initial_wait: float
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
	# save vars
	timer_initial_wait = timer.wait_time
	# packed
	packeddemon = preload("res://scenes/demon.tscn")
	# spawn demon immediately
	_on_timer_timeout()
	
	# signals
	Globals.reset_game.connect(reset)
	Globals.pause_game.connect(pause_timer)
	Globals.resume_game.connect(resume_timer)
	Globals.end_game.connect(pause_timer)
	# rate
	ratetimer.wait_time = rate_every_s
	ratetimer.stop()
	ratetimer.start()
	ratetimer.timeout.connect(increase_rate)

func reset() -> void:
	timer.wait_time = timer_initial_wait
	timer.stop()
	timer.start()
	ratetimer.stop()
	ratetimer.start()

func increase_rate() -> void:
	var new_time = (timer.wait_time - rate_subtract_s) * rate_multiply
	timer.wait_time = max(new_time, rate_minimum_s)

func pause_timer() -> void:
	timer.paused = true
	ratetimer.paused = true
func resume_timer() -> void:
	timer.paused = false
	ratetimer.paused = false   

func _on_timer_timeout() -> void:
	var newdemon: Demon = packeddemon.instantiate()
	var spawning_angle = rng.randf_range(0.0, 2*PI)
	var spawning_distance = 320 # px
	newdemon.position = Vector2(
		ELLIPSE_X_RADIUS * sin(spawning_angle),
		ELLIPSE_Y_RADIUS  * cos(spawning_angle)
	)
	newdemon.walk_towards = Vector2(0,0)
	Globals.demons.append(newdemon)
	Globals.total_demons += 1
	add_child(newdemon)
