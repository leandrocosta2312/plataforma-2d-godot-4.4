extends Node2D

enum MOVE_SET {LEFT, RIGHT, UP, DOWN}
const WAIT_DURATION = 1.0
@export var move_speed = 3.0
@export var distance = 192
## Left and Right only Horizontal
@export var move_initial_direction = MOVE_SET.RIGHT
@onready var plataform = $platform as AnimatableBody2D

var follow = Vector2.ZERO
var platform_center = 16
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_plataform()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	plataform.position = plataform.position.lerp(follow, 0.5)
	
func move_plataform():
	var move_direction = Vector2.RIGHT
	match move_initial_direction:
		MOVE_SET.UP:
			move_direction = Vector2.UP
		MOVE_SET.DOWN:
			move_direction = Vector2.DOWN			
		MOVE_SET.LEFT:
			move_direction = Vector2.LEFT
	var direction = move_direction * distance
	var duration = direction.length() / float(move_speed * platform_center)	
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "follow", direction, duration).set_delay(WAIT_DURATION)
	tween.tween_property(self, "follow", Vector2.ZERO, duration).set_delay(WAIT_DURATION * 2)
