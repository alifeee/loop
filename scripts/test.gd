extends Node2D

func _process(delta: float) -> void:
	print("areas", $Loop1.get_overlapping_areas())
	print("bodies", $Loop1.get_overlapping_bodies())
