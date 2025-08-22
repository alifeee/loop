extends Node2D

@export var wizards_array: Array[AnimatedSprite2D]
@export var portal_location: Node2D

func _ready() -> void:
	Globals.player_hit.connect(animate_wizard_death)
	Globals.enter_portal.connect(enter_portal)

## kill wizard N based on player health X
func animate_wizard_death(wizard_number: int):
	var deathtween = get_tree().create_tween()
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 0.1)
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 1, 0.1)
	deathtween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 1)

func enter_portal():
	for wizard in wizards_array:
		var tween = get_tree().create_tween()
		tween.tween_property(
			wizard, "scale", Vector2(0,0), 1.5
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(
			wizard, "position", portal_location.position, 1.5
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(
			wizard, "modulate:a", 0, 0.5
		)
