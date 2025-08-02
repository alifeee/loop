extends Area2D

@export var wizards_array: Array[AnimatedSprite2D]
@export var hats_array: Array[Sprite2D]

func _ready() -> void:
	Globals.player_hit.connect(animate_wizard_death)
	Globals.reset_game.connect(reset)
	Globals.purchase_hat.connect(buyhat)

func reset() -> void:
	for wizard in wizards_array:
		wizard.modulate.a = 1

func _on_body_entered(body: Node2D) -> void:
	if body is Demon:
		body.reach_middle()

func animate_wizard_death(wizard_number: int):
	var tween = get_tree().create_tween()
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 0.1)
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 1, 0.1)
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 1)
	print("Someone got hit... :( " + str(wizard_number))

func buyhat():
	if Globals.motes < 20:
		return
	print("you bought hat")
	for hat in hats_array:
		if not hat.visible:
			Globals.motes -= 20
			hat.visible = true
			break
