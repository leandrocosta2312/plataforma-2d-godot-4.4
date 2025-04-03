extends Node

const DAMAGE_NUMBER_SCENE = preload("res://prefabs/damage_number.tscn")

func display_number(value: int, position: Vector2):
	var label_scene = DAMAGE_NUMBER_SCENE.instantiate()
	var label_number = label_scene.get_node("label")
	label_number.text = str(value)
	
	label_scene.global_position = position
	label_scene.z_index = 5		
	call_deferred("add_sibling", label_scene)
	
	await label_scene.resized
	
	var tween = get_tree().create_tween()
	tween.tween_property(
		label_scene, "position:y", label_scene.position.y - 36, 0.25
	).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	label_scene.queue_free()
	
	
	
