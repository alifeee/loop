class_name Demon
extends AnimatableBody2D

@export var sprite: AnimatedSprite2D
@export var walk_towards: Vector2
@export var walk_speed: float = 50
var health: float = 100
var dead: bool = false
var hittween: Tween

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)

func pause() -> void:
	sprite.pause()
func play() -> void:
	sprite.play()   

func _physics_process(delta: float) -> void:
	if dead:
		return
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		return
	var distance = delta * walk_speed
	var direction_unit_vec = (walk_towards - position).normalized()
	position = position + direction_unit_vec * distance

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
	var dietween = get_tree().create_tween()
	dietween.tween_property(self, "modulate:a", 0, 2)
	dietween.tween_callback(func(): self.queue_free())
	Globals.demons.erase(self)

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
 
