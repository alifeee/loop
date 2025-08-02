extends Node2D

@export var loop1: Loop
@export var LOOP_SPRITE_DISTANCE: float = 5
@export var LOOP_FIRST_SEGMENT_MAGNETISM = 20
@export var LOOP_RADIUS: float = 50
@export var LOOP_MIN_SIZE = 60
@export var LOOP_THICCNESS = 2
@export var DAMAGE_PERCENT: float = 50

var mouse_positions: Array[Vector2] = []
var loop_segments: Array[Sprite2D] = []
var is_held = false
var packed_loop_segment: PackedScene

func _init() -> void:
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")

func do_loop_damage(position: Vector2, radius: float) -> void:
	loop1.position = position
	print(Globals.demons)
	for demon in Globals.demons:
		#print("distance: ", demon.global_position.distance_to(position))
		if demon.global_position.distance_to(position) < radius:
			#print("demon is hit !", demon)
			demon.hit(DAMAGE_PERCENT)
			
func add_loop_segment(pos1: Vector2, pos2: Vector2):
	var dist = pos1.distance_to(pos2)
	var midpoint = pos1.move_toward(pos2, dist / 2)
	
	var loop: Sprite2D = packed_loop_segment.instantiate()
	loop.position = midpoint
	loop.rotation = pos1.angle_to_point(pos2) + PI / 2
	loop.apply_scale(Vector2(LOOP_THICCNESS, dist / 2))
	
	loop_segments.append(loop)
	add_child(loop)


func add_mouse_position(v2: Vector2) -> void:
	mouse_positions.append(v2)
	
	if len(mouse_positions) > 2:
		# add segment to current loop
		add_loop_segment(mouse_positions[-1], mouse_positions[-2])
		
		# check for loop closing
		if mouse_positions[-1].distance_to(mouse_positions[0]) < LOOP_FIRST_SEGMENT_MAGNETISM:
			var mx = Vector2(-INF, -INF) # we calculate the max and min xy
			var mi = Vector2(INF, INF)
			for pos in mouse_positions:
				mx = mx.max(pos)
				mi = mi.min(pos)
				
			var dist = mi.distance_to(mx)

			print(mx, mi, dist)
			
			if dist > LOOP_MIN_SIZE:
				add_loop_segment(mouse_positions[-1], mouse_positions[0])
				finish_mouse_loop()


func finish_mouse_loop():
	is_held = false

	# work out centroid of loop
	# There needs to be some kind of weighting by distance
	var tot_vector = Vector2(0,0)
	for pos in mouse_positions:
		tot_vector = tot_vector + pos

	var avg_vector = tot_vector / len(mouse_positions)
	mouse_positions = []

	# move loop and trigger actions
	do_loop_damage(avg_vector, LOOP_RADIUS)

	# delete sprite segments
	for loop_segment in loop_segments:
		loop_segment.queue_free()
	loop_segments = []


func _input(event):
	# pause game
	if event.is_action_pressed("Pause"):
		# is playing, pause
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			Globals.pause()
			finish_mouse_loop()

		# if paused, play
		elif Globals.gamestate == Globals.GAMESTATES.PAUSED:
			Globals.resume()

	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		# start looping!  
		if event is InputEventMouseButton and event.is_pressed():
			is_held = true

		# stop looping!
		if event is InputEventMouseButton and event.is_released():
			finish_mouse_loop()

		# calculate distance difference
		if is_held and (len(mouse_positions) == 0 or (len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > LOOP_SPRITE_DISTANCE)):
			add_mouse_position(event.position)
