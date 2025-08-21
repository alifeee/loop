extends Node2D

@export var drop_scene: PackedScene
@export var drop_chance: float = 1
@export var drop_amount: int = 1
@export var drop_variance: float = 0.1

signal demon_death(pos: Vector2)

func make_drop() -> void:
	for __ in drop_amount:
		if drop_chance >= randf():
			var drop = drop_scene.instantiate()
			drop.position = self.position + Vector2(randfn(0, drop_variance), randfn(0, drop_variance))
			self.add_child(drop)
