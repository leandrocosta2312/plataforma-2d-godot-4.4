extends CharacterBody2D
class_name EnemyBase

enum Direction {RIGTH, LEFT}
const SPEED = 1500.0
var direction = -1
var flipped = false # Variável para evitar loops
@onready var anim = $anim

@export var enemy_score: int = 100 # Pontos dados ao player ao morrer

@export_group("Grounded Enemy Settings")
@export var initial_direction = Direction.LEFT
@export var grounded_enemy: bool  = false # Se é um inimigo terrestre ou nao
@export var sprite_enemy: Sprite2D
@export var wall_detector_raycast: RayCast2D # Detector de muros caso seja um inimigo terrestre
@export var ground_detector_raycast: RayCast2D # Detector de chao caso seja um inimigo terrestre

@export_group("Spawn another sprite")
@export var spawn: bool = false
@export var spawn_instance: PackedScene
@export var spawn_instance_position: Marker2D

func _ready_base():
	print("Ready para ser implementado nas classes filhas caso necessario")
	
func _ready() -> void:
	_ready_base()
	if grounded_enemy:
		assert (wall_detector_raycast != null, "wall_detector é obrigatório quando grounded_enemy é true")
		assert (ground_detector_raycast != null, "ground_detector é obrigatório quando grounded_enemy é true")
		ground_detector_raycast.force_raycast_update()
		wall_detector_raycast.force_raycast_update()
		if initial_direction == Direction.RIGTH:
			flip_enemy()
	if spawn:
		assert(spawn_instance != null, "Spawn instance é obrigatorio quando spawn é igual a true")
		assert(spawn_instance_position != null, "Spawn instance position é obrigatorio quando spawn é igual a true")

func _physics_process(delta: float) -> void:
	if (grounded_enemy):
		process_grounded_enemy(delta)
		
func spawn_new_enemy():
	var instance_scene =  spawn_instance.instantiate()
	get_tree().root.add_child(instance_scene)
	instance_scene.global_position = spawn_instance_position.global_position
		
func process_grounded_enemy(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	velocity.x = direction * SPEED * delta
	
	if wall_detector_raycast.is_colliding():
		flip_enemy()
	
	if not ground_detector_raycast.is_colliding() && is_on_floor():
		if not flipped: # Só permite inverter quando ainda não foi feito
			flip_enemy()
			flipped = true
	else:
		flipped = false # Reseta o estado quando a condição muda
		
	move_and_slide()
		

func flip_enemy():
	direction *= -1
	sprite_enemy.scale.x *= -1
	wall_detector_raycast.scale.x *= -1
	
func animation_finished():
	kill_and_score()
	
func animation_finished_grounded(anim_name: String):
	if (anim_name == "hurt"):
		kill_and_score()
		
func animation_started_grounded(anim_name: String):
	if (anim_name == "hurt"):
		self.modulate = Color.FUCHSIA
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1,1,1,1), 0.25)
		await get_tree().create_timer(30.0).timeout
		
func kill_and_score():
	GlobalManager.score += enemy_score
	if spawn:
		spawn_new_enemy()
		get_parent().queue_free()
	else:
		queue_free()
