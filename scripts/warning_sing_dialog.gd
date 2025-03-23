extends Node2D

@onready var sprite : Sprite2D = $sprite
@onready var area_sign : Area2D = $area_sign

@export var dialog_data : Resource

var is_sprite_visible : bool = false

func _ready():
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	sprite.hide()

func _process(_delta):
	var overlapping_bodies = area_sign.get_overlapping_bodies()
	is_sprite_visible = overlapping_bodies.size() > 0
	if is_sprite_visible:
		sprite.show()
	else:
		sprite.hide()
		DialogManager.restart_dialog_box()

func _unhandled_input(event: InputEvent):
	if is_sprite_visible and event.is_action_pressed("interact"):
		dialog_data.position = global_position
		dialog_data.current_line = 0
		DialogManager.start_dialog(dialog_data)
		sprite.hide()

func _on_dialog_ended():
	if not is_sprite_visible:
		sprite.show()
