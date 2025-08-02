extends Control

@export var button: Button

#No Upgrade Bar UI components
@export var no_upgrade_container: Panel
@export var name_label_no_upgrade: Label
@export var price_label_no_upgrade: Label

# Upgrade Bar UI components
@export var upgrade_container: Panel
@export var name_label_upgrade: Label
@export var price_label_upgrade: Label

@export var all_bars: Array[Panel]

@export var level_3_bar_and_gap: Array[Panel]
@export var level_4_bar_and_gap: Array[Panel]
@export var level_5_bar_and_gap: Array[Panel]

# Button Variables
@export var text: String
@export var price: int
@export var current_level: int = 1
@export var max_level: int = 1

@export var empty_texture_style : StyleBoxTexture
@export var full_texture_style : StyleBoxTexture

func _ready() -> void:
	initialise_button()
	
func initialise_button() -> void:
	if max_level == 1: # No upgrade bar at the bottom
		no_upgrade_container.show()
		upgrade_container.hide()
	else: # Upgrade bar at the bottom
		upgrade_container.show()
		no_upgrade_container.hide()
	update_text(text)
	update_price(price)
	initialise_max_level(max_level)
	update_current_level(current_level)

func update_text(text_to_change_to: String) -> void:
	name_label_no_upgrade.text = text_to_change_to
	name_label_upgrade.text = text_to_change_to

func update_price(number: int) -> void:
	price_label_no_upgrade.text = str(number)
	price_label_upgrade.text = str(number)

func initialise_max_level(max_level_to_set_to: int) -> void:
	# Turn everything off
	for label in level_3_bar_and_gap:
		label.show()
	for label in level_4_bar_and_gap:
		label.show()
	for label in level_5_bar_and_gap:
		label.show()
	# Turn on the correct ones
	if max_level_to_set_to >= 3:
		for label in level_3_bar_and_gap:
			label.show()
	if max_level_to_set_to >= 4:
		for label in level_4_bar_and_gap:
			label.show()
	if max_level_to_set_to >= 5:
		for label in level_5_bar_and_gap:
			label.show()
	if max_level_to_set_to > 5:
		print("ERROR: 5 is the max level")

func update_current_level(number) -> void:
	for i in range(all_bars.size()):
		var texture_style
		if number - 1 >= i:
			texture_style = full_texture_style
		else: 
			texture_style = empty_texture_style
		
		all_bars[i].add_theme_stylebox_override (
			"panel", 
			texture_style, 
		)

func _on_button_button_down() -> void:
	print(text + " button pressed") # Replace with function body.
