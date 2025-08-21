extends Node2D

@export var runes: Sprite2D

@export var KILLS_TO_FILL: float = 20.0

func _ready() -> void:
	runes.material.set_shader_parameter("fill", 0)

func _process(_delta: float) -> void:
	runes.material.set_shader_parameter(
		"fill", Globals.kill_count / KILLS_TO_FILL
	)
