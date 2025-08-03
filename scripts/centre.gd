extends Area2D

@export var wizards_array: Array[AnimatedSprite2D]
@export var hats_array: Array[Sprite2D]

func _ready() -> void:
	Globals.player_hit.connect(animate_wizard_death)
	Globals.reset_game.connect(reset)
	Globals.purchase_hat.connect(buyhat)

func reset() -> void:
	reset_hat()

	for wizard in wizards_array:
		wizard.modulate.a = 1

func _on_body_entered(body: Node2D) -> void:
	if body is Demon:
		body.reach_middle()

func animate_wizard_death(wizard_number: int):
	var tween = get_tree().create_tween()
	
	var do_hat = wizard_number <= Globals.hats_owned
	
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 0.1)
	if(do_hat): tween.parallel().tween_property(hats_array[wizard_number], "modulate:a", 0, 0.1)
	
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 1, 0.1)
	if(do_hat): tween.parallel().tween_property(hats_array[wizard_number], "modulate:a", 1, 0.1)
	
	tween.tween_property(wizards_array[wizard_number], "modulate:a", 0, 1)
	if(do_hat): tween.parallel().tween_property(hats_array[wizard_number], "modulate:a", 0, 1)
	
	print("Someone got hit... :( " + str(wizard_number))
	
func reset_hat():
	Globals.hats_owned = 0

	for hat in hats_array:
		hat.hide()
		hat.modulate.a = 1

func buyhat():
	if Globals.motes < 20:
		return
	print("you bought hat")
	
	var i = 0
	for hat in hats_array:
		#if i + 1 >= Globals.player_health:
			#break

		if not hat.visible and wizards_array[i].visible:
			Globals.motes -= 20
			Globals.hats_owned += 1
			hat.visible = true
			break

		i += 1
