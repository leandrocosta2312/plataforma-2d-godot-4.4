extends CanvasLayer
@onready var btn_resume: Button = $container/btn_resume

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = !get_tree().paused
		get_tree().paused = !get_tree().paused
		btn_resume.grab_focus()

func _on_btn_resume_pressed() -> void:
	visible = !get_tree().paused
	get_tree().paused = !get_tree().paused


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
