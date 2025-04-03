extends CharacterBody2D

const FIREBALL = preload("res://prefabs/fireball.tscn")
const SPEED = 1500
enum Direction {RIGTH, LEFT}
var direction = -1
var flipped = false # Variável para evitar loops
@export var enemy_score: int = 100 # Pontos dados ao player ao morrer
@export var enemy_life: int =  3

@onready var anim: AnimationPlayer = $anim
@onready var player_detector: RayCast2D = $player_detector
@onready var spawn_fireball_position: Marker2D = $spawn_fireball_position
@onready var wall_detector: RayCast2D = $wall_detector
@onready var ground_detector: RayCast2D = $ground_detector
@onready var sprite: Sprite2D = $sprite

enum EnemyState {PATROL, ATTACK, HURT}
var current_state = EnemyState.PATROL
var target: CharacterBody2D = GlobalManager.player
	
func _physics_process(delta: float) -> void:	
	match(current_state):
		EnemyState.PATROL: patrol_state(delta)
		EnemyState.ATTACK: attack_state()
	
func flip_enemy():
	direction *= -1
	sprite.scale.x *= -1
	wall_detector.scale.x *= -1	
	player_detector.scale.x *= -1
	spawn_fireball_position.position.x *= -1
	
func _hit_enemy():
	anim.play("running")
	
func spawn_fireball():
	var new_fireball =  FIREBALL.instantiate()
	if sign(spawn_fireball_position.position.x) < 0:
		new_fireball.set_direction(-1)
	else:
		new_fireball.set_direction(1)
	new_fireball.global_position = spawn_fireball_position.global_position		
	add_sibling(new_fireball)
	
func patrol_state(delta):
	anim.play("running")
			
	velocity.x = direction * SPEED * delta
	
	if wall_detector.is_colliding():
		flip_enemy()
	
	if not ground_detector.is_colliding():
		if not flipped: # Só permite inverter quando ainda não foi feito
			flip_enemy()
			flipped = true
	else:
		flipped = false # Reseta o estado quando a condição mud		
		
	if (player_detector.is_colliding()):
		_change_state(EnemyState.ATTACK)
		
	move_and_slide()	

	
func attack_state():
	anim.play("shooting")	
	if (!player_detector.is_colliding()):
		_change_state(EnemyState.PATROL)
		
func hurt_state():
	anim.play("hurt")
	await anim.animation_finished
	_change_state(EnemyState.PATROL)
	enemy_life -= 1
	if (enemy_life == 0):
		GlobalManager.score += enemy_score
		queue_free()

func _change_state(newState: EnemyState):
	current_state = newState

func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body is Player):
		if (enemy_life <= 1):
			DamageNumbers.display_number(enemy_score, global_position)							
		body.jump()
		$hitbox/tap_sfx.play()
		anim.play("hurt")
		_change_state(EnemyState.HURT)
		hurt_state()
