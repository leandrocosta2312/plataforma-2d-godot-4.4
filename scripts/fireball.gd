extends CharacterBody2D

var move_speed = 60.0
var direction = 1

func _process(delta: float) -> void:
	position.x += move_speed * direction * delta
	
func set_direction(newDirection):
	direction = newDirection
	if newDirection < 0 :
		$anim.flip_h = true
	else:
		$anim.flip_h = false


func _on_notify_screen_exited() -> void:
	queue_free()
