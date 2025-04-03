extends RigidBody2D

@onready var break_box_sfx: AudioStreamPlayer = $break_box_sfx

func _on_notify_screen_exited() -> void:
	queue_free()
