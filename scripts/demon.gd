class_name Demon
extends AnimatableBody2D

@export var sprite: AnimatedSprite2D

@export var drop_scene: PackedScene
@export var drop_chance: float = 1
@export var drop_amount: int = 1
@export var drop_variance: float = 0.1

@export var walk_angle: float
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
	make_drop()
	self.walk_speed = 0
	self.modulate = Color("#f0ff")
	self.collision_layer = 2
	var dietween = get_tree().create_tween()
	dietween.tween_property(self, "modulate:a", 0, 2)
	# dietween.tween_callback(make_drop)
	dietween.tween_callback(func(): self.queue_free())
	
func make_drop() -> void:
	var d = self.find_parent("Spawner").find_child("DemonDrops")
	
	for __ in drop_amount:
		if drop_chance >= randf():
			var drop = drop_scene.instantiate()
			drop.global_position = self.global_position + Vector2(randfn(0, drop_variance), randfn(0, drop_variance))
			d.add_child(drop)


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
 
