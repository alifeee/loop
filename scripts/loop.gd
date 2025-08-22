class_name Loop
extends Node2D

var rng = RandomNumberGenerator.new()

@export var damage_timer: Timer
@export var particles: CPUParticles2D
@export var sprite: AnimatedSprite2D
@export var shapecast: ShapeCast2D
@export var DAMAGE_TIMER_WAIT: float = 0.15
@export var DAMAGE_ANIMATION_TIME: float = 0.05
@export var DAMAGE_ANIMATION_BRIGHTNESS: float = 5
@export var DIE_ANIMATION_TIME: float = 0.15
var initial_scale: Vector2 = Vector2(1,1)
var damage_radius: float = 50
var do_damage_over_time: bool = false
var flashtween: Tween

func _ready() -> void:
	damage_timer.wait_time = DAMAGE_TIMER_WAIT
	damage_timer.stop()
	damage_timer.start()
	_on_damage_timer_timeout()
	particles.emitting = false
	modulate.a = 1
	initial_scale = Globals.LOOP_SIZE_SCALE
	scale = initial_scale

func _process(delta: float) -> void:
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	## keep checking if I'm the 3rd (final) loop
	## if so, start pulsing and emitting particles etc.
	if Globals.loops.find(self) == 0 and len(Globals.loops) >= Globals.MAX_LOOPS:
		particles.emitting = true
		modulate.a = 0.8
		var time_elapsed = Time.get_ticks_msec()
		scale = (1 - sin(time_elapsed/150.) / 10.) * initial_scale
	## move towards closest demon
	if Globals.LOOP_MOVE_TOWARDS_CLOSEST_DEMON and len(Globals.demons) > 0:
		var closest_demon = null
		var closest_distance = null
		for demon in Globals.demons:
			var distance_to = demon.global_position.distance_squared_to(position)
			if not closest_distance or distance_to < closest_distance:
				closest_demon = demon
				closest_distance = distance_to
		position = lerp(
			position,
			closest_demon.global_position,
			delta * Globals.LOOP_MOVE_TOWARDS_CLOSEST_DEMON_SPEED
		)

## die animation - spin away
func die():
	Globals.loops.erase(self)
	damage_timer.stop()
	
	var direction = -1 if rng.randi() % 2 else 1
	
	var dietween = get_tree().create_tween()
	dietween.tween_property(
		self, "modulate:a", 0, DIE_ANIMATION_TIME
	)
	dietween.parallel().tween_property(
		self, "scale", Vector2(0,0), DIE_ANIMATION_TIME
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	dietween.parallel().tween_property(
		self, "rotation", direction * PI/4, DIE_ANIMATION_TIME
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	dietween.tween_callback(queue_free)

## do damage to all demons within range
func _on_damage_timer_timeout() -> void:
	# do shapecast to find colliding bodies
	shapecast.force_shapecast_update()
	var dmg_done = false
	for result in shapecast.collision_result:
		var object = result.collider
		if object is Demon and (not object.dead):
			object.hit(Globals.LOOP_DAMAGE_PER_HIT)
			dmg_done = true

	# flash if any damage done
	if not dmg_done:
		return
	if flashtween:
		flashtween.kill()
	flashtween = get_tree().create_tween()
	flashtween.tween_property(
		self, "modulate:v", 1, DAMAGE_ANIMATION_TIME
	).from(DAMAGE_ANIMATION_BRIGHTNESS)
