class_name Demon
extends AnimatableBody2D

@export var walk_angle: float
@export var walk_speed: float
var health: float = 100
var dead: bool = false

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if dead:
		return
	var distance = delta * walk_speed
	position = position + Vector2(
		distance * sin(walk_angle),
		distance * cos(walk_angle)
	)

func hit(damage: float):
	health -= damage
	if health <= 0:
		# die
		dead = true
		self.walk_speed = 0
		self.modulate = Color("#f0ff")
		self.collision_layer = 2
	var tween = get_tree().create_tween()
	scale = Vector2(1.1,1.1)
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)
