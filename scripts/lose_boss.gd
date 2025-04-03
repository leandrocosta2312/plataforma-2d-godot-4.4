extends AnimatedSprite2D


func _on_anim_animation_finished(anim_name: StringName) -> void:
	queue_free()
