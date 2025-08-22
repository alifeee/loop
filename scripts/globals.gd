extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	END_SCREEN_LOSE,
	END_SCREEN_WIN,
}
var gamestate = GAMESTATES.START_SCREEN

# game states
signal gamestate_start
signal gamestate_end

# playing game stuff
signal player_hit(lives_left: int)
signal demon_killed(demon: Demon)
# portal stuff
signal lightning_kill
# win game stuff
signal runes_full
signal open_portal
signal click_portal
# lose game stuff
signal spawn_loads_of_enemies
signal kill_runes
signal close_portal
# end game stuff
signal show_score

# global variables
var demons: Array[Demon] = []
var drops: Array[Drop] = []
var loops: Array[Loop] = []
# counters
var player_health: int = 3
var total_demons: int = 0
var kill_count: int = 0
var motes: int = 0
var lifetime_motes: int = 0
var time_elapsed: float = 0
# game variables
var KILLS_TO_WIN = 20

func _ready():
	demon_killed.connect(_on_demon_killed)
	click_portal.connect(_on_click_portal)
	runes_full.connect(enable_win)
## track in-game time elapsed
func _process(delta: float) -> void:
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
## start triggered by main menu "start button"
func start_game():
	gamestate_start.emit()
## end triggered by losing too much health
func end_game():
	gamestate_end.emit()
	for loop in loops:
		loop.queue_free()
	loops.clear()
## reset all global variables
## all other (local) resets should happen when scenes are reloaded
func reset():
	# game stuff
	player_health = 3
	total_demons = 0
	kill_count = 0
	motes = 0
	lifetime_motes = 0
	time_elapsed = 0
	# kill everything
	for arr in [demons, drops, loops]:
		for item in arr:
			item.queue_free()
		arr.clear()

func hit_player(damage: int):
	player_health -= damage
	Audio.play(Audio.Sounds.PlayerHit)
	player_hit.emit(player_health)
	if player_health <= 0:
		enable_lose()
	else:
		lightning_kill.emit()
func _on_demon_killed(demon: Demon):
	if demon.killed_by_player:
		kill_count += 1
	demons.erase(demon) # remove from demon tracker
func enable_lose():
	gamestate = GAMESTATES.END_SCREEN_LOSE
	end_game()
	kill_runes.emit()
	close_portal.emit()
	spawn_loads_of_enemies.emit()
func enable_win():
	gamestate = GAMESTATES.END_SCREEN_WIN
	end_game()
	lightning_kill.emit()
	open_portal.emit()
func _on_click_portal():
	show_score.emit()

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
