class_name LoopContainer
extends Node2D

var rng = RandomNumberGenerator.new()

@export_group("Loop Drawing")
@export var packedloop: PackedScene
@export var LOOP_MAX_LENGTH: float = 500
@export var LOOP_MIN_AREA: float = 2500
@export var LOOP_MAX_START_END_DISTANCE: float = 50
@export var LOOP_SPRITE_DISTANCE: float = 5
@export_group("Loop Damage")
@export var LOOP_RADIUS: float = 50
@export var DAMAGE_PERCENT: float = 50
@export_group("Magic Visuals")
@export var packed_loop_segment: PackedScene
@export var DISPEL_DISTANCE: float = 25
@export var DISPEL_TIME: float = 0.15

## LOOP DRAWING ##
var spell_distance: float = 0
var spell_area: float = 0
# loop mouse positions tracker
var mouse_positions: Array[Vector2] = []
var loop_mouse_positions: Array[Vector2] = []
# loop sprites
var loop_segments: Array[AnimatedSprite2D] = []
# true while mouse is down (hopefully) but can force drop
var is_held = false
# true while is valid
var is_valid = false

var error = ""

func _ready() -> void:
	for child in get_children().duplicate():
		child.queue_free()

func _process(_delta: float) -> void:
	pass
	# check for validity every frame
	#   loop must be big enough
	#   loop end must be close to start
	#   once loop is valid, it stays valid
	#   ...and the centroid calculation uses only the first loop
	if len(mouse_positions) > 0:
		var is_big_enough = is_big_enough_area(mouse_positions)
		var is_close_enough = is_close_enough_to_start(mouse_positions)
		if (is_valid) or (is_big_enough and is_close_enough):
			make_spell_valid_level2()
			if not is_valid: # only set mouse positions once for final loop
				loop_mouse_positions = mouse_positions.duplicate()
			is_valid = true
			error = "valid"
		elif (not is_valid) and is_big_enough:
			make_spell_valid_level1()
			error = "not close enough"
		elif not is_valid:
			make_spell_invalid()
			error = "not big enough"
	else:
		make_spell_invalid()

func make_spell_invalid():
	for sparkle in loop_segments:
		sparkle.modulate = Color("#d9f")
		sparkle.speed_scale = 1
func make_spell_valid_level1():
	for sparkle in loop_segments:
		sparkle.modulate = Color("#d9f")
		sparkle.speed_scale = 5
func make_spell_valid_level2():
	for sparkle in loop_segments:
		sparkle.modulate = Color("#efe")
		sparkle.speed_scale = 10

func dispel():
	for sparkle in loop_segments:
		var tween = get_tree().create_tween()
		var angle = rng.randf_range(0, 2 * PI)
		var new_position = sparkle.position + Vector2(
			DISPEL_DISTANCE * cos(angle),
			DISPEL_DISTANCE * sin(angle)
		)
		var dispel_time = DISPEL_TIME if is_valid else DISPEL_TIME * 5
		tween.tween_property(
			sparkle, "position", new_position, dispel_time
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(
			sparkle, "modulate:a", 0, dispel_time
		)
		tween.tween_callback(
			sparkle.queue_free
		)

func do_loop_damage(pos: Vector2, radius: float) -> void:
	Audio.play(Audio.Sounds.LoopSuccess)
	# spawn a loop to do damage over time
	var loop: Loop = packedloop.instantiate()
	loop.position = pos
	loop.do_damage_over_time = true
	loop.damage_radius = radius
	Globals.loops.append(loop)
	add_child(loop)
	
	print("spawn loop at ", pos)
	
	# delete loop if there are now too many loops
	while len(Globals.loops) > 3:
		Globals.loops[0].die()

func is_big_enough_area(mouse_history) -> bool:
	spell_area = abs(Globals.calc_polygon_area(mouse_history))
	return spell_area > LOOP_MIN_AREA
func is_close_enough_to_start(mouse_history) -> bool:
	var start_pos = mouse_history[0]
	var end_pos = mouse_history[-1]
	return start_pos.distance_to(end_pos) < LOOP_MAX_START_END_DISTANCE

func pick_up_spell(pos):
	# mouse down: spawn sprites and reset positions
	is_held = true
	is_valid = false
	mouse_positions = [pos]
	spell_distance = 0

func drop_spell():
	# mouse up or start menu/etc: drop all sprites
	is_held = false
	# delete sprite segments
	dispel()
	mouse_positions = []
	loop_segments = []

func check_and_spawn_spell():
	# check if loop can spawn (if loop was drawn well or badly)
	#   and spawn if so
	if not is_valid:
		return
	# centroid is "centre" of mouse movements
	var centroid = Vector2(0, 0)
	for pos in loop_mouse_positions:
		centroid = centroid + (pos / len(loop_mouse_positions))
	do_loop_damage(centroid, LOOP_RADIUS)

func check_and_add_spell_point(pos):
	# if point far from previous point, and if line not too long
	#   add segment and carry on (wait for mouse up)
	var last_position = mouse_positions[-1]
	var this_position = pos
	var distance = this_position.distance_to(last_position)
	# length check
	spell_distance += distance
	if spell_distance > LOOP_MAX_LENGTH:
		drop_spell()
		return
	# new point check
	if distance > LOOP_SPRITE_DISTANCE:
		mouse_positions.append(this_position)
		# add sprite at midpoint
		var midpoint = last_position.lerp(this_position, 0.5)
		var loopsprite: AnimatedSprite2D = packed_loop_segment.instantiate()
		var num_frames = loopsprite.sprite_frames.get_frame_count("default")
		loopsprite.frame = rng.randi_range(0, num_frames)
		loopsprite.frame_progress = rng.randf_range(0, 1)
		loopsprite.position = midpoint
		loop_segments.append(loopsprite)
		add_child(loopsprite)

func _input(event):
	if event.is_action_pressed("Cheat_Add_Motes"):
		print("press cheat!")
		if OS.is_debug_build():
			Globals.motes += 100
			Globals.lifetime_motes += 100
	# pause game
	if event.is_action_pressed("Pause"):
		## is playing, pause
		#if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			#Globals.pause()
		## if paused, play
		#elif Globals.gamestate == Globals.GAMESTATES.SHOPPING:
			#Globals.resume()
		pass
	# no looping unless playing ! >:(
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		drop_spell()
		return
	# start looping!  
	if event is InputEventMouseButton and event.is_pressed() and event.is_action_pressed("Magic"):
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			pick_up_spell(event.position)
	# stop looping!
	elif event is InputEventMouseButton and event.is_released() and is_held:
		# only do this if unpaused
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			check_and_spawn_spell()
		# do this whatever the weather
		drop_spell()
	# continue looping !
	elif event is InputEventMouseMotion and is_held:
		check_and_add_spell_point(event.position)
