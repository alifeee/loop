extends Area2D

@export var wizards_array: Array[AnimatedSprite2D]
@export var hats_array: Array[Sprite2D]

func _ready() -> void:
	Globals.player_hit.connect(animate_wizard_death)

## Check for demons colliding with middle
## if found, player damage !
func _on_body_entered(body: Node2D) -> void:
	if body is Demon:
		# disable movement and collisions and slowly die
		body.walk_speed = 0
		body.collision_layer = 2
		print("at enter centre length", len(Globals.demons), " ", Globals.demons)
		Globals.hit_player(1)
		print("after hit player length ", len(Globals.demons), " ", Globals.demons)
		#body.die()
		# deal player damage

## kill wizard N based on player health X
func animate_wizard_death(wizard_number: int):
	var deathtween = get_tree().create_tween()
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 0.1)
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 1, 0.1)
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 1)
