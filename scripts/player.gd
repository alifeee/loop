extends Node2D

@export var loop1: Loop

#func _input(event):
	#if event is InputEventMouseButton and event.is_released():
		#print("mouse button event at ", event.position)
		#loop1.position = event.position
		#loop1.do_punch_and_disappear()


func _on_camera_2d_spawn_loop(v2: Vector2) -> void:
	print("mouse button event at ", v2)
	loop1.position = v2
	loop1.do_punch_and_disappear()
