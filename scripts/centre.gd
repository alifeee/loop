extends Area2D

## Check for demons colliding with middle
## if found, player damage !
func _on_body_entered(body: Node2D) -> void:
	if body is Demon:
		# disable movement and collisions and slowly die
		body.walk_speed = 0
		body.collision_layer = 2
		Globals.hit_player(1)
		body.die()
