extends Button


func _on_pressed() -> void:
	Globals.purchase_hat.emit()
