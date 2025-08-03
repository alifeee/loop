class_name Loop
extends Node2D

var rng = RandomNumberGenerator.new()

@export var damage_timer: Timer
@export var DAMAGE_TIMER_WAIT: float = 0.15
@export var DAMAGE_TIMER_DAMAGE: float = 34
@export var DAMAGE_ANIMATION_TIME: float = 0.05
@export var DAMAGE_ANIMATION_BRIGHTNESS: float = 5
@export var DIE_ANIMATION_TIME: float = 0.15
var damage_radius: float = 50
var do_damage_over_time: bool = false
var flashtween: Tween

func _ready() -> void:
	damage_timer.wait_time = DAMAGE_TIMER_WAIT
	damage_timer.stop()
	damage_timer.start()
	_on_damage_timer_timeout()

func _process(delta: float) -> void:
	pass

func die():
	Globals.loops.erase(self)
	damage_timer.stop()
	
	var direction = -1 if rng.randi() % 2 else 1
	var move_distance = 20
	
	var dietween = get_tree().create_tween()
	dietween.tween_property(
		self, "modulate:a", 0, DIE_ANIMATION_TIME
	)
	dietween.parallel().tween_property(
		self, "position", position + Vector2(direction * move_distance, move_distance/2), DIE_ANIMATION_TIME
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	dietween.parallel().tween_property(
		self, "rotation", direction * PI/4, DIE_ANIMATION_TIME
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	dietween.tween_callback(queue_free)

func _on_damage_timer_timeout() -> void:
	# do damage
	# hit everything within the circle once
	var hittable = []
	hittable.append_array(Globals.demons)
	hittable.append_array(Globals.drops)

	# check if each item is in range and hit if it is
	var dmg_done = false
	for item in hittable:
		if item.global_position.distance_to(global_position) < damage_radius:
			item.hit(DAMAGE_TIMER_DAMAGE)
			if item is Demon:
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
