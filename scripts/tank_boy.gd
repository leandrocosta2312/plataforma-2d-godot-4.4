extends CharacterBody2D

const SPEED = 5500
const BOMB_SCENE = preload("res://prefabs/bomb.tscn")
const MISSILE_SCENE = preload("res://prefabs/missile.tscn")
const LOSE_BOSS = preload("res://prefabs/lose_boss.tscn")
const FIRE_TRAIL = preload("res://particules/fire_trail.tscn")
const MAX_PARTICLES = 50
const PARTICLE_SPACING = 20


enum Direction { RIGTH, LEFT }
var direction = -1
var fire_trail_list = []

@onready var anim_tree: AnimationTree = $anim_tree
@onready var state_machine = anim_tree["parameters/playback"]
@onready var wall_detector: RayCast2D = $wall_detector
@onready var bomb_cooldown: Timer = $bomb_cooldown
@onready var missile_cooldown: Timer = $missile_cooldown
@onready var collision_hit_box: CollisionShape2D = $hit_box/collision_hit_box
@onready var sprite: Sprite2D = $sprite
@onready var bomb_point: Marker2D = $sprite/bomb_point
@onready var missile_point: Marker2D = $sprite/missile_point
@onready var collision_hurt_player: CollisionShape2D = $player_detector/collision_hurt_player
@onready var tap_sfx: AudioStreamPlayer = $tap_sfx

signal show_stairs
signal boss_has_died
signal has_started

var stats = {"turn_count": 0, "missile_count": 0, "bomb_count": 0, "lifes": 1}
var can_launch = {"missile": true, "bomb": true, "fire": true}
var player_hit = false

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	$fire_trail_particles.emitting = velocity.length() > 0
	handle_state(delta)
	update_state_logic()
	move_and_slide()

# Gerencia os estados
func handle_state(delta):
	match state_machine.get_current_node():
		"moving": handle_moving_state(delta)
		"missile_attack": handle_missile_attack_state()
		"hide_bomb": handle_hide_bomb_state()
		"vulnerable": handle_vulnerable_state()

# Métodos para cada estado
func handle_moving_state(delta):
	collision_hurt_player.set_deferred("disabled", false)
	collision_hit_box.set_deferred("disabled", true)
	if wall_detector.is_colliding():
		flip_enemy()
	velocity.x = direction * SPEED * delta
	
func launch_fire():
	if can_launch["fire"]:
		var fire_trail = FIRE_TRAIL.instantiate()
		fire_trail.global_position = global_position
		fire_trail.direction = direction
		fire_trail.emitting = true
		add_sibling(fire_trail)	
		can_launch["fire"] = false
	

func handle_missile_attack_state():
	velocity.x = 0
	await get_tree().create_timer(.75).timeout
	if can_launch["missile"]:
		launch_missile()

func handle_hide_bomb_state():
	velocity.x = 0
	await get_tree().create_timer(.75).timeout
	if can_launch["bomb"]:
		throw_bomb()

func handle_vulnerable_state():
	collision_hurt_player.set_deferred("disabled", true)
	collision_hit_box.set_deferred("disabled", false)
	can_launch["missile"] = false
	can_launch["bomb"] = false
	velocity.x = 0
	await get_tree().create_timer(2.0).timeout
	player_hit = false

# Atualiza a lógica de estados
func update_state_logic():
	if stats["lifes"] <= 0:
		set_states({"can_move": false, "is_vulnerable": false, "time_bomb": false, "time_missile": false, "dead" : true})
	elif stats["turn_count"] <= 2:
		set_states({"can_move": true, "time_missile": false, "time_bomb": false})
	elif stats["missile_count"] >= 4:
		set_states({"time_bomb": true})
		stats["missile_count"] = 0
	elif stats["bomb_count"] >= 3:
		set_states({"is_vulnerable": true})
		stats["bomb_count"] = 0
	else:
		set_states({"can_move": false, "is_vulnerable": false, "time_bomb": false, "time_missile": true})

# Configura múltiplos estados de uma vez
func set_states(states: Dictionary):
	for key in states:
		set_state(key, states[key])

func set_state(parameter_name: String, value: bool) -> void:
	anim_tree.set("parameters/conditions/" + parameter_name, value)

# Método para virar o inimigo
func flip_enemy():
	$fire_trail_particles.scale.x *= -1
	$fire_trail_particles.flip()	
	wall_detector.scale.x *= -1
	direction *= -1
	sprite.scale.x *= -1
	stats["turn_count"] += 1

# Lógica para lançar bomba
func throw_bomb():
	if stats["bomb_count"] <= 3:
		var bomb_instance = BOMB_SCENE.instantiate()
		add_sibling(bomb_instance)
		bomb_instance.global_position = bomb_point.global_position
		var randiDirectionX = randi_range(direction * 200, direction * 230)
		var randiDirectionY = randi_range(-200, -350)
		bomb_instance.apply_impulse(Vector2(randiDirectionX, randiDirectionY))
		stats["bomb_count"] += 1
		reset_cooldown(bomb_cooldown, "bomb")

# Lógica para lançar míssil
func launch_missile():
	if stats["missile_count"] <= 4:
		var missile_instance = MISSILE_SCENE.instantiate()
		add_sibling(missile_instance)
		missile_instance.global_position = missile_point.global_position
		missile_instance.set_direction(direction)
		stats["missile_count"] += 1
		reset_cooldown(missile_cooldown, "missile")

# Reseta cooldowns
func reset_cooldown(cooldown_timer: Timer, cooldown_type: String):
	can_launch[cooldown_type] = false
	cooldown_timer.start()
	
func spawn_lose_boss():
	var lose_boss = LOSE_BOSS.instantiate()
	add_child(lose_boss)
	lose_boss.global_position = position
	show_stairs.emit()
	boss_has_died.emit()

# Sinais para cooldowns
func _on_bomb_cooldown_timeout() -> void:
	can_launch["bomb"] = true

func _on_missile_cooldown_timeout() -> void:
	can_launch["missile"] = true

# Eventos adicionais
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)

func _on_hit_box_body_entered(body: Node2D) -> void:
	tap_sfx.play()
	body.jump()
	player_hit = true
	stats["turn_count"] = 0
	stats["lifes"] -= 1

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(Vector2((global_position.x - body.global_position.x) * 20, -200)	)

func _on_anim_tree_animation_started(anim_name: StringName) -> void:
	if anim_name == "show_reveal" :
		has_started.emit()


func _on_fire_trail_cooldown_timeout() -> void:
	can_launch["fire"] = true
