class_name Drop
extends AnimatableBody2D

@export var initial_varience: float = 50
@export var pickup_distance: float = 10
@export var target_opacity: float = 0.8

@export var fade_in_duration: float = 2
@export var left_alone_duration: float = 2
@export var fade_away_duration: float = 5
@export var pickup_duration: float = 1

@export var sprite: AnimatedSprite2D = self.find_child("Sprite2D")

var colleted = false
var drop_tween: Tween
var post_death_tween: Tween

func _ready() -> void:
	Globals.pause_game.connect(pause)
	Globals.resume_game.connect(play)
	
	assert(sprite, "you need to assign the sprite object")

func pause() -> void:
	sprite.pause()
	drop_tween.pause()
	
	if post_death_tween != null:
		post_death_tween.pause()

func play() -> void:
	sprite.play()
	drop_tween.play()
	if post_death_tween != null:
		post_death_tween.play()

func _on_ready() -> void:
	Globals.drops.append(self)
	
	drop_tween = get_tree().create_tween()
	
	var angle = randf() * 2 * PI
	var target_loc = Vector2(
		sin(angle),
		cos(angle),
	) * initial_varience
	
	self.modulate.a = 0
	
	drop_tween \
		.tween_property(self, "global_position", target_loc + self.global_position, fade_in_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	drop_tween.parallel() \
		.tween_property(self, "modulate", Color(1, 1, 1, target_opacity), fade_in_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	drop_tween.tween_interval(left_alone_duration)
	
	drop_tween \
		.tween_property(self, "modulate", Color(1, 1, 1, 0), fade_away_duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	# i  Ii
	# II i¬
	drop_tween.tween_callback(self.die)

func die():
	Globals.drops.erase(self)
	self.queue_free()
	
func hit(__):
	if colleted:
		return

	colleted = true
	drop_tween.stop()
	
	post_death_tween = get_tree().create_tween()

	Globals.motes+= 1
	
	post_death_tween \
		.tween_property(self, "global_position", Vector2(0, -pickup_distance) + self.global_position, pickup_duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
		
	post_death_tween \
		.tween_property(self, "modulate", Color(2, 2, 2, 0), pickup_duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	post_death_tween.tween_callback(die)
	
