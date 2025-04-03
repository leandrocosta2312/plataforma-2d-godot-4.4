extends AnimatableBody2D

const SPEED = 200
const EXPLOSION = preload("res://prefabs/explosion.tscn")

var velocity = Vector2.ZERO
var direction = -1
@onready var sprite: Sprite2D = $sprite
@onready var collision: CollisionShape2D = $collision

func _ready() -> void:
	set_direction(1)

func _process(delta: float) -> void:
	velocity.x = SPEED * direction * delta	
	move_and_collide(velocity)
	
func set_direction(dir):
	direction = dir
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _on_area_detector_body_entered(body: Node2D) -> void:
	visible = false
	var explosion_instance = EXPLOSION.instantiate()
	add_sibling(explosion_instance)
	explosion_instance.global_position = global_position
	collision.set_deferred("disabled", true)			
	await explosion_instance.animation_finished
	queue_free()
