extends Node2D

@export var loop1: Loop

var mouse_positions: Array[Vector2] = []
var sprites: Array[Sprite2D] = []
var is_held = false

var packed_loop_segment: PackedScene
func _ready() -> void:
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")


func add_mouse_position(v2: Vector2):
	mouse_positions.append(v2)
	
	if len(mouse_positions) > 2:
		var pos1 = mouse_positions[-1]
		var pos2 = mouse_positions[-2]
		var dist = pos1.distance_to(pos2)
		var midpoint = pos1.move_toward(pos2, dist / 2)
		
		var loop: Sprite2D = packed_loop_segment.instantiate()
		loop.position = midpoint
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
			if len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > 5:
				add_mouse_position(event.position)
