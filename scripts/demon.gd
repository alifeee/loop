class_name Demon
extends AnimatableBody2D

@export var walk_angle: float
@export var walk_speed: float
var health: float = 100
var dead: bool = false
var hittween: Tween

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dead:
		return
	var distance = delta * walk_speed
	position = position + Vector2(
		distance * sin(walk_angle),
		distance * cos(walk_angle)
	)

func hit(damage: float):
	#print("got hit")
	if hittween:
		hittween.kill()
	hittween = get_tree().create_tween()
	scale = Vector2(1.2,1.2)
	
	hittween.tween_property(self, "scale", Vector2(1,1,), 0.1)
	self.modulate = Color("#f0ff")
	hittween.parallel().tween_property(self, "modulate", Color("#ffff"), 0.1)
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	Globals.demons.remove_at(
		Globals.demons.find(self)
	)
	if hittween:
		hittween.kill()
	dead = true
	self.walk_speed = 0
	self.modulate = Color("#f0ff")
	self.collision_layer = 2
	var dietween = get_tree().create_tween()
	dietween.tween_property(self, "modulate:a", 0, 2)
	dietween.tween_callback(func(): self.queue_free())
