extends CanvasLayer

var rng = RandomNumberGenerator.new()

@export var timerLabel: Label
@export_group("UpgradeScreen")
@export var upgradeScreen: Control
@export var loopcounter: Label
@export var whatsnextlabel: Label
@export var upgrade1label: Label
@export var upgrade2label: Label
@export_group("EndGameBox")
@export var endGameScreen: Control
@export var resultLabel: Label
@export var timeTakenLabel: Label
@export var killsLabel: Label

var upgrade_choices = [
	"MORE LOOPS",
	"STRONGER LOOPS",
	"BIGGER LOOPS",
	"STICKY LOOPS",
	"TINY LOOPS",
	"DEATH LIGHTNING",
	"SLOWING SPELL",
	"QUICKER SUMMONING",
	"SPARKS",
	"LIGHTNING TRAP",
	"NECROMANCY",
]

func _ready():
	endGameScreen.visible = false
	upgradeScreen.visible = false
	Globals.show_score.connect(show_on_end)
	Globals.show_upgrades.connect(show_upgrades)
	Globals.hide_upgrades.connect(hide_upgrades)

func show_upgrades():
	upgradeScreen.visible = true
	# central text
	loopcounter.text = str(Globals.combat_round - 1) + "/3"
	if Globals.combat_round > Globals.ROUNDS_UNTIL_PORTAL:
		whatsnextlabel.text = "ESCAPE"
	else:
		whatsnextlabel.text = "FACE NEXT LOOP"
	# upgrades
	var upgrades = upgrade_choices.duplicate()
	var choice1 = upgrades[rng.randi() % upgrades.size()]
	upgrades.erase(choice1)
	var choice2 = upgrades[rng.randi() % upgrades.size()]
	upgrade1label.text = choice1
	upgrade2label.text = choice2

func hide_upgrades():
	upgradeScreen.visible = false

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
