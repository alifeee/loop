extends Node2D

var rng = RandomNumberGenerator.new()
var packeddemon: PackedScene

func _ready() -> void:
	packeddemon = preload("res://scenes/demon.tscn")

func _on_timer_timeout() -> void:
	var newdemon: Demon = packeddemon.instantiate()
	add_child(newdemon)
	newdemon.walk_angle = rng.randf_range(0.0, 2*PI)
