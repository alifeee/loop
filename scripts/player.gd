extends Node2D

@export var loop1: Loop


var mouse_positions = []
var is_held = true


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		is_held = true

	if event is InputEventMouseButton and event.is_released():
		is_held = false
		
		print(mouse_positions)
		print("mouse button event at ", event.position)
		loop1.position = event.position
		loop1.do_punch_and_disappear()
		
	if is_held:
		print("ee")
		
		# calculate distance difference (refactor this)
		if len(mouse_positions) == 0:
			mouse_positions.append(event.position)
		else: 
			if len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > 0.5:
				mouse_positions.append(event.position)
