extends Control

func _ready() -> void:
	Globals.button_pressed.connect(handle_shop_button_pressed)
	
func handle_shop_button_pressed(button_name_id: String):
	if button_name_id == "hats":
		Globals.purchase_hat.emit()
