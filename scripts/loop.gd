class_name Loop
extends Area2D

@export var hit_timer: Timer
enum ATTACK_TYPES {DamageOverTime, Instant}
@export var attack_type: ATTACK_TYPES = ATTACK_TYPES.DamageOverTime
@export var DAMAGE_PERCENT: float = 20

var fadetween: Tween

func _process(delta: float) -> void:
	#var attack_targets = get_overlapping_bodies()
	pass

func _on_body_entered(body: Node2D) -> void:
	body.modulate = Color("#f8ff")

func _on_body_exited(body: Node2D) -> void:
	if body is Demon and not body.dead:
		body.modulate = Color("#ffff")

# damage over time
func _on_timer_timeout() -> void:
	if attack_type != ATTACK_TYPES.DamageOverTime:
		return
	var attack_targets: Array[Node2D] = get_overlapping_bodies()
	for target in attack_targets:
		if target is Demon:
			target.hit(DAMAGE_PERCENT)
	var tween = get_tree().create_tween()
	scale = Vector2(1.1,1.1)
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)

# instant attack
func do_punch_and_disappear() -> void:
	if attack_type != ATTACK_TYPES.Instant:
		return
	var attack_targets: Array[Node2D] = get_overlapping_bodies()
	for target in attack_targets:
		if target is Demon:
			target.hit(DAMAGE_PERCENT)
	modulate.a = 1
	if fadetween:
		fadetween.kill()
	fadetween = get_tree().create_tween()
	fadetween.tween_property(self, "modulate:a", 0, 0.25)
