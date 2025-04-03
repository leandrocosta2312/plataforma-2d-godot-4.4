extends CharacterBody2D
class_name Player

const SPEED = 300.0
#const JUMP_VELOCITY = -350.0
const AIR_FRICTION = 0.5

var is_taking_damage = false
var knockback_vector = Vector2.ZERO
var can_play_step_sound: bool = true

# handle jump and gravity
var jump_velocity
var gravity
var fall_gravity

@onready var jump_sfx: AudioStreamPlayer = $jump_sfx
@onready var hurt_sfx: AudioStreamPlayer = $hurt_sfx
@onready var anim = $anim as AnimatedSprite2D

@export var lifes: int = 5
@export var jump_height = 80
@export var max_time_to_peak = 0.5

signal player_has_died()

func _ready() -> void:
	jump_velocity = (jump_height * 2) / max_time_to_peak
	gravity = (jump_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2
	GlobalManager.lifes = lifes
	GlobalManager.coins = 0
	GlobalManager.score = 0

func _physics_process(delta: float) -> void:
	velocity.x = 0	
	# Add the gravity.
	if not is_on_floor():
		velocity.x = 0 
		
	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		jump()
		jump_sfx.play()
		
	if velocity.y > 0 or not Input.is_action_pressed("up"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right") 
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
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
	velocity.y = -jump_velocity
	
func has_lifes() -> bool:
	return lifes > 0


func _on_hurtbox_body_entered(body: Node2D) -> void:
	var direction =  Vector2((global_position.x - body.global_position.x) * 20, -200)	
	if (body.is_in_group("enemies")):
		take_damage(direction)
	if (body.is_in_group("fireball")):
		take_damage(direction)
		body.queue_free()
		
func follow_camera(camera: Camera2D):
	pass
	#$remote.remote_path = camera.get_path()
	
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
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		if collider:
			if collider.is_in_group("fall_platform"):
				collider.has_collided_with(collision, self)

	
func _on_head_colision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("breakbox")):
		if body.has_method("break_sprite"):
			body.break_sprite(1)

func _on_foot_colision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("breakbox")):
		if body.has_method("break_sprite"):
			jump()			
			body.break_sprite(body.hitpoints + 1)	


func _on_step_sfx_finished() -> void:
	can_play_step_sound = true


func _on_magnetism_area_entered(area: Area2D) -> void:
	if (area.is_in_group("coin")):
		area.go_to_player(self)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if (area.is_in_group("fireball")):
		var direction =  Vector2((global_position.x - area.global_position.x) * 20, -200)
		take_damage(direction)
