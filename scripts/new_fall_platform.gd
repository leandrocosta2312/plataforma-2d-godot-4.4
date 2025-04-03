extends AnimatableBody2D


var velocity = Vector2.ZERO
var startGlobalPosition
var is_triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startGlobalPosition = global_position
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += get_gravity().y * delta
	position += velocity * delta


func has_collided_with(colision: KinematicCollision2D, body: CharacterBody2D) -> void:
	if (body is Player && !is_triggered):
		$anim.play("shake")
		velocity = Vector2.ZERO
		is_triggered = true
	
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shake":
		set_physics_process(true)	
		$spawn_timer.start(3)

func _on_spawn_timer_timeout() -> void:
	global_position = startGlobalPosition
	set_physics_process(false)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($sprite, "scale", Vector2(1,1), 0.3).from(Vector2.ZERO)
	is_triggered = false
