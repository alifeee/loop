extends AudioStreamPlayer

func _ready() -> void:
	self.pitch_scale *= randf_range(0.58, 1.03)
