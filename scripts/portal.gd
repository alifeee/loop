extends AnimatedSprite2D

@export var test_demons: Array[Demon]
@export var lightning_bolt_container: Node2D
@export var packedlightning: PackedScene
@export var particles: CPUParticles2D

var blinktween: Tween
var is_blinking: bool = false

func _ready():
	particles.emitting = false
	# lightning
	Globals.lightning_kill.connect(zap_all)
	# portal
	Globals.blink_portal.connect(blink_portal)
	Globals.open_portal.connect(open_portal)
	Globals.close_portal.connect(close_portal)
	Globals.splutter_portal.connect(splutter_portal)
	Globals.summon_portal.connect(summon_portal)

func close_portal():
	if animation == "portal":
		play_backwards("open_portal")
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, "modulate:a", 0, 1.5
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		self, "scale", Vector2(0,0), 1.5
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
func splutter_portal():
	play("splutter")
func summon_portal():
	play("summon_portal")
func open_portal():
	play("open_portal")
	animation_finished.connect(after_portal_opened)
func after_portal_opened():
	animation_finished.disconnect(after_portal_opened)
	play("portal")
func blink_portal(on: bool):
	if on:
		tween_blink()
		particles.emitting = true
		is_blinking = true
	elif not on and blinktween:
		blinktween.kill()
		particles.emitting = false
		is_blinking = false
func click_portal():
	if blinktween:
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

func zap_all():
	zap_demons()
	zap_loops()
func zap_demons():
	var demons = Globals.demons.duplicate()
	if test_demons:
		demons = test_demons
	for demon in demons:
		demon.die()
	zap(demons)
func zap_loops():
	var loops = Globals.loops.duplicate()
	for loop in loops.duplicate():
		loop.die()
	zap(loops)
func zap(zappables: Array):
	var lightning_bolts: Array[Line2D] = []
	for zappable in zappables:
		var lightning = packedlightning.instantiate()
		var start = Vector2(0,0)
		var end = zappable.global_position - position # relative position
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
		
		# particles
		lightning.hit_particles.position = end
		lightning.hit_particles.emitting = true
		lightning.leftover_particles.position = end
		lightning.leftover_particles.emitting = true
		
		# add to tracker
		lightning_bolts.append(lightning)
		lightning_bolt_container.add_child(lightning)
	if len(lightning_bolts) == 0:
		return
	var tween = get_tree().create_tween()
	for bolt in lightning_bolts:
		tween.parallel().tween_property(
			bolt, "self_modulate", Color(1,1,1), 0.4
		).from(Color(5,5,5))
	for bolt in lightning_bolts:
		tween.parallel().tween_property(
			bolt, "self_modulate:a", 0, 1.
		)

func _input(event: InputEvent) -> void:
	# check if clicked (or near enough)
	if (
		(Globals.gamestate == Globals.GAMESTATES.UPGRADE_SCREEN)
		and
		(event is InputEventMouseButton and event.is_released())
		and
		is_blinking
	):
		is_blinking
		if event.position.distance_to(position) < 80:
			click_portal()
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.is_released():
		# event.keycode: 48 is 0, 49 is 1, 50 is 2, etc.
		if event.keycode == 32:
			zap_all()
