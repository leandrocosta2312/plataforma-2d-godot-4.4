extends Area2D

@onready var coin_sfx: AudioStreamPlayer2D = $coin_sfx

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$anim.play("collect")
		coin_sfx.play()
		await $colision.call_deferred("queue_free")
		GlobalManager.coins += 1


func _on_anim_animation_finished() -> void:
	if ($anim.animation == "collect"):
		queue_free()
