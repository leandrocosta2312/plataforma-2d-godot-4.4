extends Area2D

@onready var anim: AnimatedSprite2D = $anim
@onready var checkpoint_sfx: AudioStreamPlayer = $checkpoint_sfx

var is_checked = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == GlobalManager.player.name and not is_checked:
		checkpoint_sfx.play()
		anim.play("rising")


func _on_anim_animation_finished() -> void:
	if anim.animation == "rising":
		is_checked = true
		anim.play("checked")
		GlobalManager.current_checkpoint = $respawn
	if anim.animation == "checked":
		$explosion.emitting = true
