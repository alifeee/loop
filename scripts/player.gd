extends Node2D

@export var loop1: Loop
@export var LOOP_SPRITE_DISTANCE: float = 5
@export var LOOP_RADIUS: float = 50
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
		loop.apply_scale(Vector2(LOOP_THICCNESS, dist / 2))
		
		loop_segments.append(loop)
		add_child(loop)
		

func finish_mouse_loop():
	pass


func _input(event):
	# pause game
	if event.is_action_pressed("Pause"):
		# is playing, pause
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			Globals.gamestate = Globals.GAMESTATES.PAUSED
			Globals.pause()
		# if paused, play
		elif Globals.gamestate == Globals.GAMESTATES.PAUSED:
			Globals.gamestate = Globals.GAMESTATES.PLAYING
			Globals.resume()
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
		do_loop_damage(avg_vector, LOOP_RADIUS)

		# delete sprite segments
		for loop_segment in loop_segments:
			loop_segment.queue_free()
		loop_segments = []

	# calculate distance difference
	if is_held and (len(mouse_positions) == 0 or (len(mouse_positions) and event.position.distance_to(mouse_positions[-1]) > LOOP_SPRITE_DISTANCE)):
		add_mouse_position(event.position)
