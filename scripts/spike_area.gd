extends Area2D

@onready var sprite: Sprite2D = $sprite
@onready var collision: CollisionShape2D = $collision


func _ready() -> void:
	collision.shape.size = sprite.get_rect().size


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(Vector2(0, -250))
		
