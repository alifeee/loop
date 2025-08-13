extends Node2D

# player !
##### THIS IS A MESS - DO NOT CHANGE WITHOUT GOOD TESTING #####

var rng = RandomNumberGenerator.new()

@export var audio_mute: CheckButton
@export_group("Loop Drawing")
@export var LOOP_CONTAINER: Node2D
@export var CONTINUOUS_CASTING: bool = true
@export var LOOP_MAX_LENGTH: float = 500
@export var LOOP_MIN_AREA: float = 2500
@export var LOOP_MAX_START_END_DISTANCE: float = 50
@export var LOOP_SPRITE_DISTANCE: float = 5
@export_group("Loop Damage")
@export var LOOP_RADIUS: float = 50
@export var PERSISTENT_SPELLS: bool = true
@export var DAMAGE_PERCENT: float = 50
@export_group("Loop Visuals")
@export var DISPEL_DISTANCE: float = 25
@export var DISPEL_TIME: float = 0.15

# for bad loop
signal error_debug(msg)
var error = ""

# loop distance tracker
var loop_distance: float = 0
# loop mouse positions tracker
var mouse_positions: Array[Vector2] = []
var loop_mouse_positions: Array[Vector2] = []
# loop sprites
var loop_segments: Array[AnimatedSprite2D] = []
# true while mouse is down (hopefully) but can force drop
var is_held = false
# true while is valid
var is_valid = false

# sprite loops for magic
var packed_loop_segment: PackedScene
# sprite loop for hit animation
var packedloop: PackedScene

func _init() -> void:
	packedloop = preload("res://scenes/loop.tscn")
	packed_loop_segment = preload("res://scenes/loop_segment.tscn")

func _ready() -> void:
	#close_button.focus_mode = Control.FOCUS_NONE
	Globals.start_game.connect(start)
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(resume)
	Globals.end_game.connect(pause)
	Globals.reset_game.connect(reset)
	Globals.win.connect(win)
	Globals.spawn_bunch_of_enemies.connect(lose)
	
	# mute/unmute
	audio_mute.focus_mode = Control.FOCUS_NONE
	
func mute_audio():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
func unmute_audio():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	
func start():
	if CONTINUOUS_CASTING:
		pick_up_spell(get_viewport().get_mouse_position())
	#$Node/TutooialThemeAudio.stop()
	#$Node/MainGameThemeAudio.play()
func pause():
	drop_spell()
func resume():
	pass
func reset():
	drop_spell()
	#$Node/MainGameThemeAudio.stop()
	#$Node/TutooialThemeAudio.play()
func win():
	pass
func lose():
	pass

func _process(delta: float) -> void:
	# check for validity every frame
	#   loop must be big enough
	#   loop end must be close to start
	#   once loop is valid, it stays valid
	#   ...and the centroid calculation uses only the first loop
	##### THIS IS A MESS - DO NOT CHANGE WITHOUT GOOD TESTING #####
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	if CONTINUOUS_CASTING:
		check_and_spawn_spell()
	if len(mouse_positions) > 0:
		var is_big_enough = is_big_enough_area(mouse_positions)
		var is_close_enough = is_close_enough_to_start(mouse_positions)
		if (is_valid) or (is_big_enough and is_close_enough):
			make_spell_valid_level2()
			if not is_valid: # only set mouse positions once for final loop
				loop_mouse_positions = mouse_positions.duplicate()
			is_valid = true
		elif (not is_valid) and is_big_enough:
			make_spell_valid_level1()
		elif not is_valid:
			make_spell_invalid()
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
		var angle = rng.randf_range(0,2*PI)
		var new_position = sparkle.position + Vector2(
			DISPEL_DISTANCE * cos(angle),
			DISPEL_DISTANCE * sin(angle)
		)
		var dispel_time =  DISPEL_TIME if is_valid else DISPEL_TIME * 5
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
	if PERSISTENT_SPELLS:
		# spawn a loop to do damage over time
		var loop: Loop = packedloop.instantiate()
		loop.position = pos
		loop.do_damage_over_time = true
		loop.damage_radius = radius
		Globals.loops.append(loop)
		LOOP_CONTAINER.add_child(loop)
		
		# delete loop if there are now too many loops
		while len(Globals.loops) > 3:
			Globals.loops[0].die()

	else:
		# hit everything within the circle once
		var hittable = []
		hittable.append_array(Globals.demons)
		hittable.append_array(Globals.drops)
	
		# check if each item is in range and hit if it is
		for item in hittable:
			if item.global_position.distance_to(pos) < radius and not item.dead:
				item.hit(DAMAGE_PERCENT)

		var loop = packedloop.instantiate()
		loop.position = pos
		var tween = get_tree().create_tween()
		tween.tween_property(loop, "modulate:a", 0, 0.5)
		tween.tween_callback(
			func(): loop.queue_free()
		)
		LOOP_CONTAINER.add_child(loop)

# checks
#func is_too_long(mouse_history) -> bool:
	#var distance = 0
	#for i in range(1,len(mouse_history)):
		#var v_from = mouse_history[i-1]
		#var v_to = mouse_history[i]
		#distance += v_from.distance_to(v_to)
	#return distance > LOOP_MAX_LENGTH
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
	dispel()
	mouse_positions = []
	loop_segments = []
	if CONTINUOUS_CASTING:
		pick_up_spell(get_viewport().get_mouse_position())

func check_and_spawn_spell():
	# check if loop can spawn (if loop was drawn well or badly)
	#   and spawn if so
	if is_valid:
		# centroid is "centre" of mouse movements
		var centroid = Vector2(0,0)
		for pos in loop_mouse_positions:
			centroid = centroid + (pos / len(loop_mouse_positions))
		do_loop_damage(centroid, LOOP_RADIUS)
		if CONTINUOUS_CASTING:
			drop_spell()

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
	if event.is_action_pressed("Cheat_Add_Motes"):
		print("press cheat!")
		if OS.is_debug_build():
			Globals.motes += 100
			Globals.lifetime_motes += 100
	# reset game
	if event.is_action_pressed("Reset"):
		print("press reset!")
		Globals.reset()
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


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		unmute_audio()
	else:
		mute_audio()
