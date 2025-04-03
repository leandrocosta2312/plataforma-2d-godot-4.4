extends GPUParticles2D

func _on_area_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(Vector2(0, -250))
		
func flip():
	if process_material is ParticleProcessMaterial:
		process_material.gravity.x = process_material.gravity.x * -1
	
