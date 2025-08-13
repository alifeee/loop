extends Node

enum Sounds {
	MainGameTheme,
	WormHit,
	LoopSuccess,
	PlayerHit,
	CollectMote,
	TutorialTheme,
	WormThud
}

@export_group("MainGameTheme")
@export var MainGameTheme_Player: AudioStreamPlayer
@export var MainGameTheme_pitchmin: float = 1
@export var MainGameTheme_pitchmax: float = 1
@export_group("WormHit")
@export var WormHit_Player: AudioStreamPlayer
@export var WormHit_pitchmin: float = 0.99
@export var WormHit_pitchmax: float = 1.01
@export_group("LoopSuccess")
@export var LoopSuccess_Player: AudioStreamPlayer
@export var LoopSuccess_pitchmin: float = 0.98
@export var LoopSuccess_pitchmax: float = 1.02
@export_group("PlayerHit")
@export var PlayerHit_Player: AudioStreamPlayer
@export var PlayerHit_pitchmin: float = 0.98
@export var PlayerHit_pitchmax: float = 1.03
@export_group("CollectMote")
@export var CollectMote_Player: AudioStreamPlayer
@export var CollectMote_pitchmin: float = 0.98
@export var CollectMote_pitchmax: float = 1.03
@export_group("TutorialTheme")
@export var TutorialTheme_Player: AudioStreamPlayer
@export var TutorialTheme_pitchmin: float = 1
@export var TutorialTheme_pitchmax: float = 1
@export_group("WormThud")
@export var WormThud_Player: AudioStreamPlayer
@export var WormThud_pitchmin: float = 0.98
@export var WormThud_pitchmax: float = 1.03

var players: Array[AudioStreamPlayer]
var pitches: Array[Array]

func _ready() -> void:
	players = [
		MainGameTheme_Player,
		WormHit_Player,
		LoopSuccess_Player,
		PlayerHit_Player,
		CollectMote_Player,
		TutorialTheme_Player,
		WormThud_Player
	]
	pitches = [
		[MainGameTheme_pitchmin, MainGameTheme_pitchmax],
		[WormHit_pitchmin, WormHit_pitchmax],
		[LoopSuccess_pitchmin, LoopSuccess_pitchmax],
		[PlayerHit_pitchmin, PlayerHit_pitchmax],
		[CollectMote_pitchmin, CollectMote_pitchmax],
		[TutorialTheme_pitchmin, TutorialTheme_pitchmax],
		[WormThud_pitchmin, WormThud_pitchmax],
	]

# for debug - press 1-9 or 0 to test sounds
func _input(event: InputEvent) -> void:
	if owner != get_tree().edited_scene_root:
		# we're in another scene, disable testing
		return
	if event is InputEventKey and event.is_released():
		# event.keycode: 48 is 0, 49 is 1, 50 is 2, etc.
		if 48 <= event.keycode and event.keycode <= 58:
			# toggle sound, key 0 is sound 0, key 1 is sound 1, etc
			play(event.keycode - 48)

func play(index: Sounds):
	if index < 0 or index >= len(players):
		return # index not in range
	# get player
	var player: AudioStreamPlayer = players[index]
	# set variable pitch
	var pitchminmax: Array = pitches[index]
	player.pitch_scale = randf_range(pitchminmax[0], pitchminmax[1])
	# start sound
	player.stream_paused = false
	player.play()
func playcurried(index: Sounds):
	return func(): play(index)

func stop(index: Sounds):
	if index < 0 or index >= len(players):
		return # index not in range
	# get player
	var player: AudioStreamPlayer = players[index]
	# set variable pitch
	var pitchminmax: Array = pitches[index]
	player.pitch_scale = randf_range(pitchminmax[0], pitchminmax[1])
	# stop sound
	player.stream_paused = true
	player.stop()
func stopcurried(index: Sounds):
	return func(): stop(index)
