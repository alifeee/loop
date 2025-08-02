extends Node2D

enum SPAWN_FROM {Centre, Outside}
@export var spawn_from: SPAWN_FROM = SPAWN_FROM.Centre
var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	packeddemon = preload("res://scenes/demon.tscn")
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	if spawn_from == SPAWN_FROM.Centre:
		print("spawning demon from centre")
		var newdemon: Demon = packeddemon.instantiate()
		newdemon.position = Vector2(0,0)
		newdemon.walk_angle = rng.randf_range(0.0, 2*PI)
		add_child(newdemon)
	if spawn_from == SPAWN_FROM.Outside:
		print("spawning demon from outside")
		var newdemon: Demon = packeddemon.instantiate()
		var spawning_angle = rng.randf_range(0.0, 2*PI)
		var spawning_distance = 320 # px
		newdemon.position = Vector2(
			spawning_distance * sin(spawning_angle),
			spawning_distance * cos(spawning_angle)
		)
		newdemon.walk_angle = spawning_angle - PI
		print(newdemon.position)
		print(newdemon.walk_angle)
		add_child(newdemon)
