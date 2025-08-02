extends Node2D

@export var loop1: Loop
@export var LOOP_SPRITE_DISTANCE: float = 5
@export var LOOP_RADIUS: float = 50

var mouse_positions: Array[Vector2] = []
var loop_segments: Array[Sprite2D] = []
var is_held = false
var packed_loop_segment: PackedScene

func _init() -> void:
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")

func do_loop_damage(position: Vector2, radius: float) -> void:
	loop1.position = position
	loop1.do_punch_and_disappear()

func add_mouse_position(v2: Vector2):
	mouse_positions.append(v2)
	var loop: Sprite2D = packed_loop_segment.instantiate()
	loop.position = v2
	loop_segments.append(loop)
	add_child(loop)

func _input(event):
	# start looping!
	if event is InputEventMouseButton and event.is_pressed():
		is_held = true
	# stop looping!
	if event is InputEventMouseButton and event.is_released():
		is_held = false
		# work out centroid of loop
		var tot_vector = Vector2(0,0)
		for pos in mouse_positions:
			tot_vector = tot_vector + pos
		var avg_vector = Vector2(
			tot_vector.x / len(mouse_positions),
			tot_vector.y / len(mouse_positions)
		)
		mouse_positions = []
		# move loop and trigger actions
		do_loop_damage(avg_vector, LOOP_RADIUS)
		# delete sprite segments
		for loop_segment in loop_segments:
			loop_segment.queue_free()
		loop_segments = []
	# continue looping !
	if is_held:
		# calculate distance difference (refactor this)
		if len(mouse_positions) == 0:
			add_mouse_position(event.position)
		else: 
			if len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > LOOP_SPRITE_DISTANCE:
				add_mouse_position(event.position)
