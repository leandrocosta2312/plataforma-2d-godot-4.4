extends Area2D
@onready var tap_sfx: AudioStreamPlayer = $tap_sfx


func _on_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		body.jump()
		tap_sfx.play()
		get_parent().anim.play("hurt")
