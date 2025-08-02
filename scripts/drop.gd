extends AnimatableBody2D

@export var initial_varience: float = 5000
@export var velocity_dropoff: float = 0.999
@export var minimal_movement: float = 1e-2

# var target_loc: Vector2

# func _physics_process(delta: float) -> void:

var drop_tween: Tween

func _on_ready() -> void:
	print("Ready!!")
	var angle = randf() * 2 * PI
	var target_loc = Vector2(
		sin(angle),
		cos(angle),
	) * initial_varience
	
	
