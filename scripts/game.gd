extends Node2D

# player !
##### THIS IS A MESS - DO NOT CHANGE WITHOUT GOOD TESTING #####

@export_group("DEBUG INFO")
@export var debuglabel: Label
@export var loopcontainer: LoopContainer
@export var spawner: Spawner

func _ready() -> void:
	Globals.set_gamestate(Globals.GAMESTATES.PLAYING)
	# play tutorial theme
	Audio.play(Audio.Sounds.TutorialTheme)

func _process(delta: float) -> void:
	fill_debug_label()

func fill_debug_label():
	var info = [
		1,
		Globals.gamestate,
		Globals.player_health,

		loopcontainer.spell_distance,
		loopcontainer.spell_area,
		len(loopcontainer.mouse_positions),
		loopcontainer.is_valid,
		loopcontainer.error,

		spawner.timer.wait_time,
		spawner.timer.time_left,
		spawner.ratetimer.wait_time,
		spawner.ratetimer.time_left,

		Globals.total_demons,
		len(Globals.demons),

		Globals.lifetime_motes,

		len(Globals.loops),
	]
	for i in range(len(info)):
		if info[i] is float:
			info[i] = snappedf(info[i], 0.01)
		info[i] = str(info[i])
	debuglabel.text = """
	DEBUG INFORMATION
	GAME VERSION: %s
	GAME STATE: %s
	
	PLAYER/HEALTH: %s
	
	SPELL/LENGTH: %s
	SPELL/AREA: %s
	SPELL/N_POSITIONS: %s
	SPELL/VALID: %s
	SPELL/INVALIDITY: %s
	
	SPAWNER/NEXT: %s
	SPAWNER/NEXT: %s
	SPAWNER/RATEUP: %s
	SPAWNER/RATEUP: %s
	
	DEMONS/TOTAL: %s
	DEMONS/CURRENT: %s
	
	MOTES/TOTAL: %s
	
	LOOPS/TOTAL: %s
	""" % info
