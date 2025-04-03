extends Control

@export var initial_scene: PackedScene
@onready var btn_start: Button = $MarginContainer/HBoxContainer/VBoxContainer/btn_start


func _ready() -> void:
	btn_start.grab_focus()

func _on_btn_start_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(initial_scene)


func _on_btn_credits_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
