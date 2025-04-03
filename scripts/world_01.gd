extends Node2D

@onready var player: CharacterBody2D = $player
@onready var control: Control = $HUD/control
@onready var player_scene = preload("res://prefabs/player.tscn")
@onready var game_over_scene = load("res://scenes/game_over_screen.tscn")
@onready var fall_zone: Area2D = $fall_zone
@onready var fireworks: Node2D = $fireworks
@onready var tank_boy: CharacterBody2D = $tank_boy
@onready var camera: Camera2D = $camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalManager.initial_position = player.global_position	
	set_player(player)
	control.time_is_up.connect(game_over)
	tank_boy.boss_has_died.connect(fireworks.show)

func _physics_process(delta: float) -> void:
	if GlobalManager.player:
		fall_zone.position.x = GlobalManager.player.position.x

func game_over():
	get_tree().change_scene_to_packed(game_over_scene)
	
func reload_game():	
	print("reload game")
	await get_tree().create_timer(1.0).timeout
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	var newPlayer = player_scene.instantiate()
	add_child(newPlayer)
	set_player(newPlayer)
	GlobalManager.respawn_player()
	camera.player_path = GlobalManager.player.get_path()
	camera.switch_target()

	
func set_player(playerToSet: CharacterBody2D):
	GlobalManager.player = playerToSet
	playerToSet.follow_camera(camera)
	playerToSet.player_has_died.connect(reload_game)

func _on_fall_zone_body_entered(body: Node2D) -> void:
	var actualPlayer = GlobalManager.player
	if (body.name == actualPlayer.name):
		actualPlayer.take_damage(Vector2.ZERO)
		if (actualPlayer.has_lifes()):
			GlobalManager.respawn_player()
	

func _on_tank_boy_has_started() -> void:
	var zoom = camera.zoom
	camera.switch_target()
	camera.position_smoothing_enabled = true
	camera.zoom = Vector2(5.0, 5.0)
	await get_tree().create_timer(2.5).timeout
	camera.position_smoothing_enabled = false
	camera.zoom = zoom
	camera.switch_target()
