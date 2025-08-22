extends CanvasLayer

@export var timerLabel: Label
@export_group("UpgradeScreen")
@export var upgradeScreen: Control
@export var loopcounter: Label
@export_group("EndGameBox")
@export var endGameBox: Panel
@export var timeTakenLabel: Label
@export var killsLabel: Label

func _ready():
	endGameBox.visible = false
	upgradeScreen.visible = false
	Globals.show_score.connect(show_on_end)
	Globals.show_upgrades.connect(show_upgrades)
	Globals.hide_upgrades.connect(hide_upgrades)

func show_upgrades():
	loopcounter.text = str(Globals.combat_round - 1) + "/3"
	upgradeScreen.visible = true
func hide_upgrades():
	upgradeScreen.visible = false

func show_on_end():
	var tween = get_tree().create_tween()
	endGameBox.modulate.a = 0
	endGameBox.visible = true
	tween.tween_property(
		endGameBox, "modulate:a", 1, 2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	timeTakenLabel.text = "Time: " + str(snapped(Globals.time_elapsed, 0.1))
	killsLabel.text = "x " + str(Globals.total_kill_count)
