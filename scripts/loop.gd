class_name Loop
extends Area2D

@export var hit_timer: Timer

func _process(delta: float) -> void:
	var attack_targets = get_overlapping_bodies()

func _on_body_entered(body: Node2D) -> void:
	body.modulate = Color("#f8ff")

func _on_body_exited(body: Node2D) -> void:
	body.modulate = Color("#ffff")


func _on_timer_timeout() -> void:
	var attack_targets: Array[Node2D] = get_overlapping_bodies()
	for target in attack_targets:
		if target is Demon:
			target.hit(20)
	var tween = get_tree().create_tween()
	scale = Vector2(1.1,1.1)
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)
