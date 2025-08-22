extends CanvasLayer


@export var timerLabel: Label
const packed_upgradeScreen: PackedScene = preload("res://scenes/upgrades.tscn")
@export var upgradeScreen: Control = null
@export_group("EndGameBox")
@export var endGameScreen: Control
@export var resultLabel: Label
@export var timeTakenLabel: Label
@export var killsLabel: Label

func _ready():
	endGameScreen.visible = false
	Globals.show_score.connect(show_on_end)
	Globals.show_upgrades.connect(show_upgrades)
	Globals.hide_upgrades.connect(hide_upgrades)

func show_upgrades():
	upgradeScreen = packed_upgradeScreen.instantiate()
	add_child(upgradeScreen)

func hide_upgrades():
	if upgradeScreen: upgradeScreen.die()

func show_on_end():
	timeTakenLabel.text = "Time: " + str(snapped(Globals.time_elapsed, 0.1))
	killsLabel.text = "x " + str(Globals.total_kill_count)
	if Globals.gamestate == Globals.GAMESTATES.WIN:
		resultLabel.text = "ESCAPED"
	else:
		resultLabel.text = "OVERRUN"
	
	var tween = get_tree().create_tween()
	endGameScreen.modulate.a = 0
	endGameScreen.visible = true
	tween.tween_property(
		endGameScreen, "modulate:a", 1, 2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
