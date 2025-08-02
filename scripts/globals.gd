extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	SHOPPING,
	WIN_SCREEN
}
var gamestate = GAMESTATES.START_SCREEN

# game state signals
signal start_game
signal pause_game
signal resume_game
signal end_game
signal reset_game
# other signals
signal player_hit(lives_left: int)

# global variables
var demons: Array[Demon] = []
var drops: Array[Drop] = []
# counters
var player_health: int = 3
var total_demons: int = 0
var kill_count: int = 0
var motes: int = 0
var time_elapsed: float = 0

func _ready() -> void:
	#start()
	pass

func _process(delta: float) -> void:
	if Globals.gamestate == Globals.GAMESTATES.PLAYING:
		time_elapsed += delta

func delete_reset_array(ar: Array):
	for i in ar:
		i.queue_free()
	ar.clear()

func start():
	gamestate = GAMESTATES.PLAYING
	start_game.emit()
	## kill mobs
	delete_reset_array(demons)
	delete_reset_array(drops)
	print("starting game")
func pause():
	gamestate = GAMESTATES.SHOPPING
	pause_game.emit()
	print("pausing game")
func resume():
	gamestate = GAMESTATES.PLAYING
	resume_game.emit()
	print("resuming game")
func endgame():
	gamestate = GAMESTATES.WIN_SCREEN
	pause()
	end_game.emit()
	var hittables = []
	hittables.append_array(Globals.demons)
	for hittable in hittables:
		hittable.hit(100)
	print("ending game")
func reset():
	gamestate = GAMESTATES.START_SCREEN
	# normal stuff
	reset_game.emit()
	print("resetting game")
	# game stuff
	player_health = 3
	total_demons = 0
	motes = 0
	time_elapsed = 0
	## kill mobs
	delete_reset_array(demons)
	delete_reset_array(drops)
	## reset timers (in player script)
	## drop spell (in portal script)
	resume()

func hit_player(damage: int):
	player_health -= 1
	if player_health <= 0:
		endgame()
	player_hit.emit(player_health)

func calc_polygon_area(coords) -> float:
	# coords is Array[Vector2]
	# from https://www.wikihow.com/Calculate-the-Area-of-a-Polygon
	#print(coords)
	var sum1 = 0
	var sum2 = 0
	for i in range(len(coords)):
		#print("loop ", i)
		var mod = len(coords)
		var i1 = (i) % mod
		var i2 = (i + 1) % mod
		#print("grab 1 xi ", i1, "  yi ", i2)
		#print("  (", coords[i1].x, " and ", coords[i2].y, ")")
		#print("  mult ", coords[i1].x * coords[i2].y)
		sum1 += (coords[i1].x * coords[i2].y)
		var j1 = (i + 1) % mod
		var j2 = (i) % mod
		#print("grab 2 xi ", j1, "  yi ", j2)
		#print("  (", coords[j1].x, " and ", coords[j2].y, ")")
		#print("  mult ", coords[j1].x * coords[j2].y)
		sum2 += (coords[j1].x * coords[j2].y)
	#print("sum1: ", sum1)
	#print("sum2: ", sum2)
	#print((sum1 - sum2) / 2)
	return (sum1 - sum2) / 2
