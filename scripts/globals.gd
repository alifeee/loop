extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	UPGRADE_SCREEN,
	END_SCREEN_LOSE,
}
var gamestate = GAMESTATES.START_SCREEN

# game states
signal gamestate_start

# playing game stuff
signal player_hit(lives_left: int)
signal demon_killed(demon: Demon)
# portal stuff
signal lightning_kill
signal blink_portal(bool)
signal splutter_portal
signal summon_portal
# lose game stuff
signal spawn_loads_of_enemies
signal kill_runes
signal close_portal
# upgrade stuff
signal show_upgrades
signal hide_upgrades
# win game stuff
signal runes_full
signal open_portal
signal click_portal
signal enter_portal
# end game stuff
signal show_score

# global variables
var demons: Array[Demon] = []
var drops: Array[Drop] = []
var loops: Array[Loop] = []
# health tracker
var player_health: int = 3
# total counters
var total_demons_spawned: int = 0
var total_kill_count: int = 0
var time_elapsed: float = 0
# round counters
var combat_round = 1
var ROUNDS_UNTIL_PORTAL = 3
var TIME_TO_WIN = 2
var round_progress: float = 0

func _ready():
	demon_killed.connect(_on_demon_killed)
	click_portal.connect(_on_click_portal)
	runes_full.connect(enable_upgrade_picker)
## track in-game time elapsed
func _process(delta: float) -> void:
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
		round_progress += delta
## start triggered by main menu "start button"
func start_game():
	gamestate_start.emit()
## reset all global variables
## all other (local) resets should happen when scenes are reloaded
func reset():
	# game stuff
	player_health = 3
	total_demons_spawned = 0
	total_kill_count = 0
	time_elapsed = 0
	combat_round = 1
	round_progress = 0
	# kill everything
	for arr in [demons, drops, loops]:
		for item in arr:
			item.queue_free()
		arr.clear()

# misc
func _on_demon_killed(demon: Demon):
	if demon.killed_by_player:
		total_kill_count += 1
	demons.erase(demon) # remove from demon tracker

# LOSE STUFF
func hit_player(damage: int):
	player_health -= damage
	Audio.play(Audio.Sounds.PlayerHit)
	player_hit.emit(player_health)
	if player_health <= 0:
		enable_lose()
func enable_lose():
	gamestate = GAMESTATES.END_SCREEN_LOSE
	kill_runes.emit()
	close_portal.emit()
	spawn_loads_of_enemies.emit()

# round stuff
func enable_upgrade_picker():
	gamestate = GAMESTATES.UPGRADE_SCREEN
	lightning_kill.emit()
	combat_round += 1
	show_upgrades.emit()
	if combat_round > ROUNDS_UNTIL_PORTAL: # win (portal fully opens)
		open_portal.emit()
	else: # just another round (splutter)
		round_progress = 0
		splutter_portal.emit()
	# wait 2s for portal to be clickable
	await get_tree().create_timer(2).timeout
	blink_portal.emit(true)
func _on_click_portal():
	blink_portal.emit(false)
	if combat_round > ROUNDS_UNTIL_PORTAL: # win
		kill_runes.emit()
		enter_portal.emit()
		show_score.emit()
		await get_tree().create_timer(2).timeout
		close_portal.emit()
	else: # next round
		gamestate = GAMESTATES.PLAYING
		summon_portal.emit()
		blink_portal.emit(false)
		hide_upgrades.emit()

func calc_polygon_area(coords) -> float:
	# coords is Array[Vector2]
	# from https://www.wikihow.com/Calculate-the-Area-of-a-Polygon
	var sum1 = 0
	var sum2 = 0
	for i in range(len(coords)):
		var mod = len(coords)
		var i1 = (i) % mod
		var i2 = (i + 1) % mod
		sum1 += (coords[i1].x * coords[i2].y)
		var j1 = (i + 1) % mod
		var j2 = (i) % mod
		sum2 += (coords[j1].x * coords[j2].y)
	return (sum1 - sum2) / 2
