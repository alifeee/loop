extends Node2D

@export var timer: Timer
var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	packeddemon = preload("res://scenes/demon.tscn")
	_on_timer_timeout()
	Globals.pause_game.connect(stop_timer)
	Globals.resume_game.connect(start_timer)

func stop_timer() -> void:
	timer.stop()
func start_timer() -> void:
	timer.start()

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
