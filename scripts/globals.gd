extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	PAUSED,
	WIN_SCREEN
}
var gamestate = GAMESTATES.START_SCREEN

# signals
signal reset_game
signal pause_game
signal resume_game
signal start_game
signal end_game
signal player_hit

# global variables
@export var INITIAL_PLAYER_HEALTH: int = 3
var player_health: int = 3
var total_demons = 0
var demons: Array[Demon] = []
var drops: Array[Drop] = []
var kill_count = 0
var motes = 0


func delete_reset_array(ar: Array):
	for i in ar:
		i.queue_free()
	
	ar.clear()

func reset():
	# normal stuff
	gamestate = GAMESTATES.START_SCREEN
	reset_game.emit()
	print("resetting game")
	# game stuff
	player_health = INITIAL_PLAYER_HEALTH
	## kill mobs
	total_demons = 0
	motes = 0
	delete_reset_array(demons)
	delete_reset_array(drops)
	
	## reset timers (in signal)
	## drop spell (in signal)
	resume()
	
func start():
	gamestate = GAMESTATES.START_SCREEN
	start_game.emit()
	print("starting game")

func pause():
	gamestate = GAMESTATES.PAUSED
	pause_game.emit()
	print("pausing game")

func resume():
	gamestate = GAMESTATES.PLAYING
	resume_game.emit()
	print("resuming game")

func endgame():
	pause()
	end_game.emit()
	gamestate = GAMESTATES.WIN_SCREEN
	var hittables = []
	hittables.append_array(Globals.demons)
	for hittable in hittables:
		hittable.hit(100)
	print("ending game")

func hit_player(damage: int):
	player_health -= 1
	if player_health <= 0:
		endgame()
	player_hit.emit()

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
