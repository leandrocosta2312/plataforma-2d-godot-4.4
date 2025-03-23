extends RigidBody2D

func _on_notify_screen_exited() -> void:
	queue_free()
