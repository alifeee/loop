extends Node2D

@export var loop1: Loop


var mouse_positions = []
var is_held = true

var packed_loop_segment: PackedScene
func _ready() -> void:
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")


func add_mouse_position(v2: Vector2):
	mouse_positions.append(v2)
	var loop: Sprite2D = packed_loop_segment.instantiate()
	loop.position = v2
	add_child(loop)

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
		# calculate distance difference (refactor this)
		if len(mouse_positions) == 0:
			add_mouse_position(event.position)
		else: 
			if len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > 0.5:
				add_mouse_position(event.position)
