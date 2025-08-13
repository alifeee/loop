extends Node2D

# control script ! for game states

@export var sceneNode: Node2D

@export var splashScreen_Scene: PackedScene
@export var game_Scene: PackedScene

func _ready() -> void:
	Globals.gamestate_reset.connect(load_splashScreen)
	# load splash
	load_splashScreen()
	# load game
	Globals.gamestate_start.connect(load_game)

func load_scene(scene: PackedScene):
	# delete existing scene…
	for child in sceneNode.get_children():
		child.queue_free()
	# add new scene
	var live_scene = scene.instantiate()
	sceneNode.add_child(live_scene)

func load_splashScreen():
	load_scene(splashScreen_Scene)
func load_game():
	load_scene(game_Scene)

func _input(event):
	# reset game
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()
		Globals.reset()
