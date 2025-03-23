extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0

var is_taking_damage = false
var knockback_vector = Vector2.ZERO
var can_play_step_sound: bool = true
@onready var step_sfx: AudioStreamPlayer = $step_sfx
@onready var break_box_sfx: AudioStreamPlayer = $break_box_sfx
@onready var hit_box_sfx: AudioStreamPlayer = $hit_box_sfx
@onready var jump_sfx: AudioStreamPlayer = $jump_sfx
@onready var hurt_sfx: AudioStreamPlayer = $hurt_sfx
@onready var anim = $anim as AnimatedSprite2D
@export var lifes: int = 10

signal player_has_died()

func _ready() -> void:
	GlobalManager.lifes = lifes
	GlobalManager.coins = 0
	GlobalManager.score = 0

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		jump()
		jump_sfx.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right") 
	if direction:
		velocity.x = direction * SPEED
		# flip
		anim.scale.x = direction
		if is_on_floor() and can_play_step_sound:
			can_play_step_sound = false
			#step_sfx.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if (knockback_vector != Vector2.ZERO):
		velocity = knockback_vector
		
	_set_state()
	verify_collision_and_emit_signal()	

	move_and_slide()

		
func jump():
	velocity.y = JUMP_VELOCITY

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemies")):
		var direction =  Vector2((global_position.x - body.global_position.x) * 20, -200)
		take_damage(direction)
		
func follow_camera(camera: Camera2D):
	$remote.remote_path = camera.get_path()
	
func take_damage(knockback_force = Vector2.ZERO, duration = 0.25):
	hurt_sfx.play()	
	if (GlobalManager.lifes > 0):
		GlobalManager.lifes -= 1
	else:
		queue_free()
		player_has_died.emit()

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	anim.modulate = Color("red")
	tween.parallel().tween_property(anim, "modulate", Color(1,1,1,1), duration)
	is_taking_damage = true
	await get_tree().create_timer(.3).timeout
	is_taking_damage = false
	
func _set_state():
	var state = "idle"
	if !is_on_floor():
		state = "jump"
	elif velocity.x != 0:
		state = "run"				
	if is_taking_damage:
		state = "hurt"		
		
	anim.play(state)
	
func verify_collision_and_emit_signal():
	for index in get_slide_collision_count():
		var colision = get_slide_collision(index)
		if (colision.get_collider().has_method("has_collided_with")):	
			colision.get_collider().has_collided_with(colision, self)
	
func _on_head_colision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("breakbox")):
		if body.has_method("break_sprite"):
			body.break_sprite(1)
			hit_box_sfx.play()


func _on_foot_colision_body_entered(body: Node2D) -> void:
	jump()
	if (body.is_in_group("breakbox")):
		if body.has_method("break_sprite"):
			body.break_sprite(body.hitpoints + 1)	
			break_box_sfx.play()


func _on_step_sfx_finished() -> void:
	can_play_step_sound = true
