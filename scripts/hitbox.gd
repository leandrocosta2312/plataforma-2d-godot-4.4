extends Area2D
@onready var tap_sfx: AudioStreamPlayer = $tap_sfx

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		body.jump()
		tap_sfx.play()
		if get_parent() is EnemyBase:
			var enemy = get_parent() as EnemyBase
			enemy.anim.play("hurt")
			if (enemy.enemy_life <= 1):
				DamageNumbers.display_number(enemy.enemy_score, global_position)
