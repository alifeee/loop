extends Node2D
## Main game script. mainly debug info and game start

@export_group("DEBUG INFO")
@export var debuglabel: Label
@export var debuglabel2: Label
@export var loopcontainer: LoopContainer
@export var spawner: Spawner

func _ready() -> void:
	Globals.gamestate = Globals.GAMESTATES.PLAYING
	# play tutorial theme
	Audio.play(Audio.Sounds.MainGameTheme)

func _process(_delta: float) -> void:
	fill_debug_label()

func fill_debug_label():
	var info = [
		1,
		Globals.gamestate,
		Globals.time_elapsed,
		
		Globals.combat_round,
		Globals.round_progress,

		Globals.player_health,
		Globals.PORTAL_ZAP_ALL_DEMONS_ON_LIFE_LOSS,
		
		loopcontainer.spell_distance,
		loopcontainer.spell_area,
		len(loopcontainer.mouse_positions),
		loopcontainer.is_valid,
		loopcontainer.error,

		spawner.timer.wait_time,
		spawner.timer.time_left,
		spawner.ratetimer.wait_time,
		spawner.ratetimer.time_left,

		Globals.DEMON_MOVE_SPEED,
		len(Globals.demons),
		Globals.total_demons_spawned,

		len(Globals.loops),
		Globals.LOOP_DAMAGE_PER_HIT,
		Globals.LOOP_SIZE_SCALE,
		Globals.LOOP_MOVE_TOWARDS_CLOSEST_DEMON,
		Globals.LOOP_MOVE_TOWARDS_CLOSEST_DEMON_SPEED,
	]
	for i in range(len(info)):
		if info[i] is float:
			info[i] = snappedf(info[i], 0.01)
		info[i] = str(info[i])
	debuglabel.text = """DEBUG INFORMATION
	GAME/VERSION: %s
	GAME/STATE: %s
	GAME/TIMER: %s
	ROUND/N: %s
	ROUND/TIMER: %s
	PLAYER/HEALTH: %s
	PLAYER/ZAP_ON_HIT: %s
	SPELL/LENGTH: %s
	SPELL/AREA: %s
	SPELL/N_POSITIONS: %s
	SPELL/VALID: %s
	SPELL/INVALIDITY: %s
	SPAWNER/NEXT: %s
	SPAWNER/NEXT: %s
	SPAWNER/RATEUP: %s
	SPAWNER/RATEUP: %s
	DEMONS/MOVESPEED: %s
	DEMONS/CURRENT: %s
	DEMONS/TOTAL: %s
	LOOPS/TOTAL: %s
	LOOPS/DAMAGE: %s
	LOOPS/SCALE: %s
	LOOPS/MOVE: %s
	LOOPS/MOVE_SPEED: %s
	""" % info
	
	var upgrade_text = ""
	for upgrade: Upgrade in Globals.upgrades.duplicate():
		upgrade_text += upgrade.name_
		upgrade_text += ": "
		upgrade_text += "1" if upgrade.is_enabled else "-"
		upgrade_text += "\n"
	debuglabel2.text = upgrade_text
