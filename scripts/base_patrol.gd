extends Node2D

enum FollowDirection{UP, DOWN}
@export var follow_direction: FollowDirection = FollowDirection.UP
@onready var anim: AnimationPlayer = $anim

func _ready() -> void:
	if (follow_direction == FollowDirection.DOWN):
		anim.play("patrol_reverse")
