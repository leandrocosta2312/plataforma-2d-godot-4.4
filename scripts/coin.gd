extends Area2D

const SPEED_MAGNETISM = 200.0
@onready var coin_sfx: AudioStreamPlayer2D = $coin_sfx

var nodeToFollow: Node2D = null
var interpolationPeso = 0.0  

func _process(delta: float) -> void:
	if nodeToFollow:
		var direction =  global_position.direction_to(nodeToFollow.global_position)
		var move_step = direction * SPEED_MAGNETISM * delta
		if global_position.distance_to(nodeToFollow.global_position) <= move_step.length():
			global_position = nodeToFollow.global_position
			nodeToFollow = null
		else:
			global_position += move_step			
			### Exemplo com interpolaca suave
			#interpolationPeso += delta * 0.5
			#interpolationPeso = clamp(interpolationPeso, 0.0, 1.0)
			#var current_position = lerp(global_position, node.global_position, interpolationPeso) # Calcula a posição atual
			#global_position = current_position			

		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		$anim.play("collect")
		coin_sfx.play()
		await $colision.call_deferred("queue_free")
		GlobalManager.coins += 1
		
func go_to_player(node):
	nodeToFollow = node


func _on_anim_animation_finished() -> void:
	if ($anim.animation == "collect"):
		queue_free()
