class_name Demon
extends AnimatableBody2D

var rng = RandomNumberGenerator.new()

# for changing animations
@export var sprite: AnimatedSprite2D
@export var collisionshape: CollisionShape2D
# tween times
@export var spawn_anim_duration: float = 2.
@export var hit_anim_duration: float = 0.1
@export var death_duration: float = 2
# behaviour
@export var walk_towards: Vector2
var walk_speed: float = 50
var do_slow_appear: bool = false
# health tracking
@export var health: float = 100
var dead: bool = false
var killed_by_player: bool = false

## Tweens
var hittween: Tween

func _ready() -> void:
	walk_speed = Globals.DEMON_MOVE_SPEED
	# spaw in on random animation frame
	var num_frames = sprite.sprite_frames.get_frame_count("default")
	sprite.frame = rng.randi_range(0, num_frames)
	sprite.frame_progress = rng.randf_range(0, 1)
	if do_slow_appear:
		slow_appear()
		return
	# fade in
	var twn = get_tree().create_tween()
	modulate.a = 0
	twn.tween_property(
		self, "modulate:a", 1, spawn_anim_duration
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	# change facing direction
	if position.x > 0:
		sprite.scale.x = -1  # Facing right
		collisionshape.scale.x = -1
	else:
		sprite.scale.x = 1 # Facing left
		collisionshape.scale.x = 1

func _physics_process(delta: float) -> void:
	if dead:
		return
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	var distance = delta * walk_speed
	var direction_unit_vec = (walk_towards - position).normalized()
	position = position + direction_unit_vec * distance

## do hit animation, track health & death, and sounds
func hit(damage: float):
	hittween = get_tree().create_tween()
	hittween.tween_property(
		self, "scale", Vector2(1,1), hit_anim_duration
	).from(Vector2(1.2,1.2))
	hittween.parallel().tween_property(
		self, "modulate:v", 1, hit_anim_duration
	).from(5)
	health -= damage
	if health <= 0:
		killed_by_player = true
		die()
	Audio.play(Audio.Sounds.WormThud)

func die() -> void:
	Globals.demon_killed.emit(self)
	if hittween:
		hittween.kill()
	dead = true
	self.walk_speed = 0
	self.modulate = Color("#f0ff")
	self.collision_layer = 2

	Audio.play(Audio.Sounds.WormHit)
	
	sprite.play("death")
	await get_tree().create_timer(1).timeout
	self.queue_free()
 
## Used at the end of the game to randomly delay appearing
func slow_appear() -> void:
	var delay = rng.randf_range(0.1, 3)
	var spawn_time = rng.randf_range(1.5, 3)
	var tween = get_tree().create_tween()
	tween.tween_interval(delay)
	tween.tween_property(
		self, "modulate:a", 1, spawn_time
	)
