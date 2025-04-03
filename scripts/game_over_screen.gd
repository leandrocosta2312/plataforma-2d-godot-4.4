extends Control

@onready var btn_restart: Button = $HBoxContainer/VBoxContainer/btn_restart
@onready var btn_main_menu: Button = $HBoxContainer/VBoxContainer/btn_main_menu
@onready var btn_quit: Button = $HBoxContainer/VBoxContainer/btn_quit

func _ready() -> void:
	btn_restart.grab_focus()
	TransitionScreen.transition_fade_in()
	await TransitionScreen.on_transition_finished

func _on_btn_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world_01.tscn")

func _on_btn_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
