class_name Demon
extends AnimatableBody2D

@export var sprite: AnimatedSprite2D
@export var DemonDrops: Node2D

@export var drop_scene: PackedScene
@export var drop_chance: float = 1
@export var drop_amount: int = 1
@export var drop_variance: float = 0.1

@export var death_duration: float = 2
@export var moat_spawn_delay: float = 1.5

@export var walk_towards: Vector2
@export var walk_speed: float = 50
var health: float = 100
var dead: bool = false

## Tweens
var hittween: Tween
var spawn_tween: Tween
var dietween: Tween 


func pause_tween(tw):
	if tw != null:
		tw.pause()

func play_tween(tw):
	if tw != null:
		tw.play()

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	
	assert(moat_spawn_delay < death_duration)

func pause() -> void:
	for x in [sprite, hittween, spawn_tween, dietween]:
		pause_tween(x)

func play() -> void:
	for x in [sprite, hittween, spawn_tween, dietween]:
		play_tween(x)

func _physics_process(delta: float) -> void:
	if dead:
		return
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	var distance = delta * walk_speed
	var direction_unit_vec = (walk_towards - position).normalized()
	position = position + direction_unit_vec * distance
	if position.x > 0:
		$AnimatedSprite2D.scale.x = -1  # Facing right
	elif position.x < 0:
		$AnimatedSprite2D.scale.x = 1 # Facing left

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
	if hittween:
		hittween.kill()
	dead = true
	self.walk_speed = 0
	self.modulate = Color("#f0ff")
	self.collision_layer = 2

	spawn_tween = get_tree().create_tween()
	spawn_tween.tween_interval(moat_spawn_delay)
	spawn_tween.tween_callback(make_drop)
	
	dietween = get_tree().create_tween()
	dietween.tween_property(self, "modulate:a", 0, death_duration)
	dietween.tween_callback(func(): self.queue_free())
	
	Globals.demons.erase(self)
	
func make_drop() -> void:
	for __ in drop_amount:
		if drop_chance >= randf():
			var drop = drop_scene.instantiate()
			drop.global_position = self.position + Vector2(randfn(0, drop_variance), randfn(0, drop_variance))
			DemonDrops.add_child(drop)


func reach_middle() -> void:
	# stop
	self.walk_speed = 0
	self.collision_layer = 2
	# grow
	var growtween = get_tree().create_tween()
	growtween.tween_property(self, "scale", Vector2(1.5,1.5), 3)
	growtween.parallel().tween_property(
		self, "modulate:a", 0, 3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# subtract health
	Globals.hit_player(1)
	# die
	die()
 
