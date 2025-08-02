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

# global variables
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
