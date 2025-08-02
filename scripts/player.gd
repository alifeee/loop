extends Node2D

@export var loop1: Loop
@export var LOOP_SPRITE_DISTANCE: float = 5
@export var LOOP_THICCNESS = 2

var mouse_positions: Array[Vector2] = []
var loop_segments: Array[Sprite2D] = []
var is_held = false
var packed_loop_segment: PackedScene

func _init() -> void:
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
		loop.rotation = pos1.angle_to_point(pos2) + PI / 2
		loop.apply_scale(Vector2(LOOP_THICCNESS, dist))
		
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

		var avg_vector = tot_vector / len(mouse_positions)
		mouse_positions = []

		# move loop and trigger actions
		loop1.position = avg_vector
		loop1.do_punch_and_disappear()

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
