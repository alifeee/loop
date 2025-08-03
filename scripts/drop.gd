class_name Drop
extends AnimatableBody2D

@export var initial_varience: float = 50
@export var pickup_distance: float = 10
@export var target_opacity: float = 0.8

@export var uncertainty: float = 1
@export var invul_duration: float = 2
@export var invul_in_duration: float = 2
@export var fade_in_duration: float = 2
@export var left_alone_duration: float = 2
@export var fade_away_duration: float = 5
@export var pickup_duration: float = 0.5

@export var sprite: AnimatedSprite2D
@export var allow_sprite_flip: bool = true

var dead = true
var drop_tween: Tween
var post_death_tween: Tween

var sprite_playing = false


"""
Lifespan of a mote:
 - Spawn in invis (fade_in_duration)
 - [wait (invul_duration)]
 - Slowly fade in
 - Become pickable
 - slowly fade away
"""

func _ready() -> void:
	Globals.pause_game.connect(pause)
	# Globals.end_game.connect(pause) # they can fade away now
	Globals.resume_game.connect(play)
	
	# might as well try to find the sprite
	if sprite == null:
		sprite = self.find_child("Sprite2D")
	
	assert(sprite, "you need to assign the sprite object")
	
	sprite.pause()


func pause() -> void:
	print("PAUSED")
	sprite.pause()
	drop_tween.pause()
	
	if post_death_tween != null:
		post_death_tween.pause()


func play() -> void:
	if sprite_playing:
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
	
	self.modulate = Color("#006b5700")
	
	# add variance
	if allow_sprite_flip:
		sprite.flip_h = randi_range(0, 1) == 1
		sprite.flip_v = randi_range(0, 1) == 1
		sprite.rotate(PI * 2 * (randi() % 4))

	drop_tween \
		.tween_property(self, "global_position", target_loc + self.global_position, invul_in_duration + randf() * uncertainty) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	drop_tween.parallel() \
		.tween_property(self, "modulate", Color("#5252527d"), invul_in_duration) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	
	drop_tween.tween_interval(invul_duration + randf() * uncertainty)
	drop_tween.tween_callback(func(): 
		self.dead = false
		self.sprite_playing = true
		sprite.play()
	)
	
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
	if dead:
		return
	
	Globals.sound_collect_mote.emit()

	dead = true
	drop_tween.stop()
	
	post_death_tween = get_tree().create_tween()

	Globals.motes+= 1
	
	post_death_tween \
		.tween_property(self, "global_position", Vector2(0, -pickup_distance) + self.global_position, pickup_duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
			
	post_death_tween \
		.parallel() \
		.tween_property(self, "modulate", Color(2, 2, 2, 1), pickup_duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	post_death_tween \
		.tween_property(self, "modulate", Color(2, 2, 2, 0), pickup_duration) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	post_death_tween.tween_callback(die)
	
