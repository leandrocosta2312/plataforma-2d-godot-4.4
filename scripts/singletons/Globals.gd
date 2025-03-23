class_name Globals extends Node

var coins: int = 0
var score: int = 0
var lifes: int = 0
var player: CharacterBody2D
var current_checkpoint: Marker2D
var initial_position: Vector2

func respawn_player():
	if current_checkpoint:
		player.position = current_checkpoint.global_position
	else:
		player.position = initial_position
