extends AnimatedSprite2D

@export var test_demons: Array[Demon]
@export var lightning_bolt_container: Node2D
@export var packedlightning: PackedScene

var blinktween: Tween

func _ready():
	Globals.lightning_kill.connect(zap_enemies)
	Globals.open_portal.connect(open_portal)
	Globals.close_portal.connect(close_portal)

func close_portal():
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "modulate:a", 0, 3
	)
	tween.parallel().tween_property(
		self, "scale", Vector2(0,0), 3
	)
func open_portal():
	print("open portal")
	play("open_portal")
	animation_finished.connect(blink_portal)
func blink_portal():
	print("blink portal")
	animation_finished.disconnect(blink_portal)
	play("portal")
	tween_blink()
func click_portal():
	blinktween.kill()
	modulate = Color(1,1,1)
	Globals.click_portal.emit()

func tween_blink():
	if blinktween: blinktween.kill()
	blinktween = get_tree().create_tween()
	blinktween.tween_property(
		self, "modulate", Color(5,5,5), 0.15
	)
	blinktween.tween_property(
		self, "modulate", Color(1,1,1), 0.15
	)
	blinktween.tween_interval(0.4)
	blinktween.tween_callback(tween_blink)

func zap_enemies():
	var lightning_bolts: Array[Line2D] = []
	var demons = Globals.demons.duplicate()
	#var demons = [$"../Demon", $"../Demon2", $"../Demon3", $"../Demon4"]
	for demon in demons:
		demon.die()
		var lightning: Line2D = packedlightning.instantiate()
		var start = Vector2(0,0)
		var end = demon.global_position - position # relative position
		var angle = start.angle_to_point(end)
		
		lightning.clear_points()
		lightning.add_point(start)
		for i in range(1,3):
			lightning.add_point(lerp(start, end, i/3.))
			lightning.add_point(lerp(start, end, i/3.) + Vector2(
				10 * cos(angle - 3*PI/4),
				10 * sin(angle - 3*PI/4)
			))
		lightning.add_point(end)
		
		# add to tracker
		lightning_bolts.append(lightning)
		lightning_bolt_container.add_child(lightning)
	if len(lightning_bolts) == 0:
		return
	var tween = get_tree().create_tween()
	for bolt in lightning_bolts:
		tween.parallel().tween_property(
			bolt, "modulate", Color(1,1,1), 0.4
		).from(Color(5,5,5))
	for bolt in lightning_bolts:
		tween.parallel().tween_property(
			bolt, "modulate:a", 0, 1.
		)
	for bolt in lightning_bolts:
		tween.parallel().tween_property(
			bolt, "scale", Vector2(1,1), 1.
		).from(
			Vector2(1,1)
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	# check if clicked (or near enough)
	if ((Globals.gamestate == Globals.GAMESTATES.END_SCREEN_WIN) 
		and event is InputEventMouseButton
		and event.is_released()):
		if event.position.distance_to(position) < 80:
			click_portal()
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.is_released():
		# event.keycode: 48 is 0, 49 is 1, 50 is 2, etc.
		if event.keycode == 32:
			zap_enemies()
