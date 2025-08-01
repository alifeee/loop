extends Node2D

@export var loop1: Loop

func _input(event):
	if event is InputEventMouseButton and event.is_released():
		print("mouse button event at ", event.position)
		loop1.position = event.position
