extends Node2D

@onready var player: CharacterBody2D = $player
@onready var control: Control = $HUD/control
@onready var player_scene = preload("res://prefabs/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalManager.initial_position = player.global_position
	set_player(player)
	control.time_is_up.connect(game_over)

func game_over():
	get_tree().reload_current_scene()
	
func reload_game():
	await get_tree().create_timer(1.0).timeout
	var newPlayer = player_scene.instantiate()
	add_child(newPlayer)
	set_player(newPlayer)
	GlobalManager.respawn_player()
	
func set_player(playerToSet: CharacterBody2D):
	GlobalManager.player = playerToSet
	playerToSet.follow_camera($camera)
	playerToSet.player_has_died.connect(reload_game)
