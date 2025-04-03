extends CanvasLayer
@onready var btn_resume: Button = $container/btn_resume

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause()
		btn_resume.grab_focus()

func _on_btn_resume_pressed() -> void:
	pause()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_btn_menu_pressed() -> void:
	pause()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	
func pause():
	visible = !get_tree().paused
	get_tree().paused = !get_tree().paused
