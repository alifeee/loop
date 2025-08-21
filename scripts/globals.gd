extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	END_SCREEN,
}
var gamestate = GAMESTATES.START_SCREEN

# game states
signal gamestate_start
signal gamestate_end

# signals
signal player_hit(lives_left: int)

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

## track in-game time elapsed
func _process(delta: float) -> void:
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta
## start triggered by main menu "start button"
func start_game():
	gamestate_start.emit()
## end triggered by losing too much health
func end_game():
	gamestate = GAMESTATES.END_SCREEN
	gamestate_end.emit()
	for demon in demons:
		demon.die()
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
		end_game()

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
