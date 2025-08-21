extends CanvasLayer

@export var timerLabel: Label
@export var timeTakenLabel: Label
@export var killsLabel: Label

func _ready():
	visible = false
	Globals.gamestate_end.connect(show_on_end)

func _process(_delta: float) -> void:
	timerLabel.text = str(snapped(Globals.time_elapsed, 0.1))

func show_on_end():
	visible = true
	timeTakenLabel.text = "Time: " + str(snapped(Globals.time_elapsed, 0.1))
	killsLabel.text = "x " + str(Globals.kill_count)
