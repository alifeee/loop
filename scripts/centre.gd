extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Demon:
		body.reach_middle()
