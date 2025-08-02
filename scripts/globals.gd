extends Node2D

# game states
enum GAMESTATES {
	START_SCREEN,
	PLAYING,
	PAUSED,
	WIN_SCREEN
}
var gamestate = GAMESTATES.PLAYING

# signals
signal pause_game
signal resume_game
signal end_game
signal player_hit

# global variables
@export var player_health: int = 3
var total_demons = 0
var demons: Array[Demon] = []

func pause():
	gamestate = GAMESTATES.PAUSED
	pause_game.emit()
	print("pausing game")

func resume():
	gamestate = GAMESTATES.PLAYING
	resume_game.emit()
	print("resuming game")

func endgame():
	gamestate = GAMESTATES.WIN_SCREEN
	end_game.emit()
	print("ending game")

func hit_player(damage: int):
	player_health -= 1
	if player_health <= 0:
		endgame()
	player_hit.emit()
