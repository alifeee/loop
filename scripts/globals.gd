extends Node2D

enum GAMESTATE {
	START_SCREEN,
	PLAYING,
	PAUSED,
	WIN_SCREEN
}

var demons: Array[Demon] = []

@export var amicool: bool
