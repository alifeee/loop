extends Node2D

func _ready():
	var coords = [
		Vector2(-3, -2),
		Vector2(-1, 4),
		Vector2(6, 1),
		Vector2(3, 10),
		Vector2(-4, 9)
	]
	print(Globals.calc_polygon_area(coords))
