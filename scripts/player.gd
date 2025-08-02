extends Node2D

# player !

var rng = RandomNumberGenerator.new()

signal error_debug(msg)
var error = ""

@export_group("assets")
@export var loop1: Loop
@export_group("Loop Drawing")
@export var LOOP_MAX_LENGTH: float = 500
@export var LOOP_MIN_AREA: float = 2500
@export var LOOP_MAX_START_END_DISTANCE: float = 50
@export var LOOP_SPRITE_DISTANCE: float = 5
@export_group("Loop Damage")
@export var LOOP_RADIUS: float = 50
@export var DAMAGE_PERCENT: float = 50

var loop_distance: float = 0
var mouse_positions: Array[Vector2] = []
var loop_segments: Array[Node2D] = []
var is_held = false
var is_valid = false

var packed_loop_segment: PackedScene
var packedloop: PackedScene

func _init() -> void:
	packedloop = preload("res://scenes/loop.tscn")
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")

func _ready() -> void:
	Globals.reset()
	Globals.reset_game.connect(reset)

func _process(delta: float) -> void:
	if len(mouse_positions) > 0:
		is_valid = is_big_enough_area(mouse_positions) and is_close_enough_to_start(mouse_positions)
		if is_valid:
			make_spell_valid()
	else:
		is_valid = false
		make_spell_invalid()

func reset():
	drop_spell()

func make_spell_invalid():
	for sparkle in loop_segments:
		sparkle.modulate = Color("#fff")
func make_spell_valid():
	for sparkle in loop_segments:
		sparkle.modulate = Color("#f66")

func do_loop_damage(pos: Vector2, radius: float) -> void:
	# check if each demon is in range and hit if it is
	for demon in Globals.demons:
		#print("distance: ", demon.global_position.distance_to(position))
		if demon.global_position.distance_to(pos) < radius:
			#print("demon is hit !", demon)
			demon.hit(DAMAGE_PERCENT)
	var loop = packedloop.instantiate()
	loop.position = pos
	var tween = get_tree().create_tween()
	tween.tween_property(loop, "modulate:a", 0, 0.5)
	tween.tween_callback(
		func(): loop.queue_free()
	)
	add_child(loop)

# checks
func is_big_enough_area(mouse_history) -> bool:
	var polygon_area = abs(Globals.calc_polygon_area(mouse_history))
	return polygon_area > LOOP_MIN_AREA
func is_close_enough_to_start(mouse_history) -> bool:
	var start_pos = mouse_history[0]
	var end_pos = mouse_history[-1]
	return start_pos.distance_to(end_pos) < LOOP_MAX_START_END_DISTANCE

func pick_up_spell(pos):
	# mouse down: spawn sprites and reset positions
	is_held = true
	is_valid = false
	mouse_positions = [pos]
	loop_distance = 0

func drop_spell():
	# mouse up or start menu/etc: drop all sprites
	is_held = false
	# delete sprite segments
	for loop_segment in loop_segments:
		loop_segment.queue_free()
	mouse_positions = []
	loop_segments = []

func check_and_spawn_spell():
	# check if loop can spawn (if loop was drawn well or badly)
	#   and spawn if so
	error = ""
	#### POLYGON AREA CHECK ####
	if not is_big_enough_area(mouse_positions):
		error = "loop not big enough"
	#### START/END DISTANCE CHECK ####
	if not is_close_enough_to_start(mouse_positions):
		error = "start too far from end"
	#### SUCCESS ####
	if error == "":
		# centroid is "centre" of mouse movements
		var centroid = Vector2(0,0)
		for pos in mouse_positions:
			centroid = centroid + (pos / len(mouse_positions))
		do_loop_damage(centroid, LOOP_RADIUS)
	#### FAIL ####
	else:
		error_debug.emit(error)

func check_and_add_spell_point(pos):
	# if point far from previous point, and if line not too long
	#   add segment and carry on (wait for mouse up)
	var last_position = mouse_positions[-1]
	var this_position = pos
	var distance = this_position.distance_to(last_position)
	# length check
	loop_distance += distance
	if loop_distance > LOOP_MAX_LENGTH:
		error_debug.emit("length too long!!!!")
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
		loopsprite.position = pos
		loop_segments.append(loopsprite)
		add_child(loopsprite)

func _input(event):
	# reset game
	if event.is_action_pressed("Reset") and not is_held:
		Globals.reset()
	# pause game
	elif event.is_action_pressed("Pause") and not is_held:
		# is playing, pause
		if Globals.gamestate == Globals.GAMESTATES.PLAYING:
			Globals.pause()
		# if paused, play
		elif Globals.gamestate == Globals.GAMESTATES.PAUSED:
			Globals.resume()
	# start looping!  
	elif event is InputEventMouseButton and event.is_pressed() and event.is_action_pressed("Magic"):
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
