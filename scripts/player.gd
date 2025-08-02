extends Node2D

# player !

var rng = RandomNumberGenerator.new()

signal error_debug(msg)
var error = ""

@export_group("assets")
@export var loop1: Loop
@export_group("Loop Drawing")
@export var LOOP_MIN_AREA: float = 2500
@export var LOOP_MAX_START_END_DISTANCE: float = 50
@export var LOOP_SPRITE_DISTANCE: float = 5
@export_group("Loop Damage")
@export var LOOP_RADIUS: float = 50
@export var DAMAGE_PERCENT: float = 50

var mouse_positions: Array[Vector2] = []
var loop_segments: Array[Node2D] = []
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

func _input(event):
	# pause game
	if event.is_action_pressed("Pause") and not is_held:
		# is playing, pause
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			Globals.pause()
		# if paused, play
		elif Globals.gamestate == Globals.GAMESTATES.PAUSED:
			Globals.resume()
	# start looping!  
	elif event is InputEventMouseButton and event.is_pressed() and event.is_action_pressed("Magic"):
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			is_held = true
			mouse_positions.append(event.position)
	# stop looping!
	elif event is InputEventMouseButton and event.is_released() and is_held:
		# only do this if unpaused
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			# work out centroid of loop
			var centroid = Vector2(0,0)
			for pos in mouse_positions:
				centroid = centroid + (pos / len(mouse_positions))
			# loop checks
			error = ""
			#### RECTANGLE (not used) SIZING ####
			if false:
				var loop_rect = Rect2(mouse_positions[0], Vector2(0,0))
				for mouse_position in mouse_positions:
					loop_rect = loop_rect.expand(mouse_position)
				var rect_area = loop_rect.get_area()
				print("position:", loop_rect.position)
				print("end:", loop_rect.end)
				print("area:", rect_area)
				print("polgon area!")
				$position.position = loop_rect.position
				$end.position = loop_rect.end
				if rect_area > LOOP_MIN_AREA:
					# move loop and trigger actions
					do_loop_damage(centroid, LOOP_RADIUS)
				else:
					error.emit("loop not big enough")
			#### POLYGON SIZING ####
			var polygon_area = abs(Globals.calc_polygon_area(mouse_positions))
			if polygon_area < LOOP_MIN_AREA:
				error = "loop not big enough"
			#### START/END DISTANCE ####
			var start_pos = mouse_positions[0]
			var end_pos = mouse_positions[-1]
			if start_pos.distance_to(end_pos) > LOOP_MAX_START_END_DISTANCE:
				error = "start too far from end"
			if error == "":
				do_loop_damage(centroid, LOOP_RADIUS)
			else:
				error_debug.emit(error)
		# do this whatever the weather
		is_held = false
		# delete sprite segments
		for loop_segment in loop_segments:
			loop_segment.queue_free()
		mouse_positions = []
		loop_segments = []
	# continue looping !
	elif event is InputEventMouseMotion and is_held:
		#print(event)
		var last_position = mouse_positions[-1]
		var this_position = event.position
		if this_position.distance_to(last_position) > LOOP_SPRITE_DISTANCE:
			mouse_positions.append(this_position)
			# add sprite at midpoint
			var midpoint = last_position.lerp(this_position, 0.5)
			var loopsprite: AnimatedSprite2D = packed_loop_segment.instantiate()
			var num_frames = loopsprite.sprite_frames.get_frame_count("default")
			loopsprite.frame = rng.randi_range(0, num_frames)
			loopsprite.frame_progress = rng.randf_range(0, 1)
			loopsprite.position = event.position
			loop_segments.append(loopsprite)
			add_child(loopsprite)
