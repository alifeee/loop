extends Control

@export var mote_count_label: Label

func _ready() -> void:
	Globals.button_pressed.connect(handle_shop_button_pressed)
	
func _process(delta: float) -> void:
	update_mote_count(Globals.motes)
	
func handle_shop_button_pressed(button_name_id: String):
	if button_name_id == "hats":
		Globals.purchase_hat.emit()

func update_mote_count(number_of_motes: int):
	mote_count_label.text = str(number_of_motes)
	
