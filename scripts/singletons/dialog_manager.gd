extends Node

signal dialog_started(dialog_resource)
signal dialog_ended()

@onready var dialog_box_scene = preload("res://prefabs/dialog_box.tscn")

var dialog_resource : Resource = null
var dialog_box : Node = null
var is_dialog_active : bool = false
var can_advance_message: bool = false

func start_dialog(dialog_resource_to_start : Resource):
	if is_dialog_active:
		return
	dialog_resource = dialog_resource_to_start
	is_dialog_active = true
	dialog_started.emit(dialog_resource)
	show_dialog_line()

func show_dialog_line():
	if dialog_resource.current_line >= dialog_resource.lines.size():
		end_dialog()
		return
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_dialog_line_displayed)
	get_tree().root.add_child(dialog_box)
	dialog_box.global_position = dialog_resource.position
	dialog_box.start_display_text(dialog_resource.lines[dialog_resource.current_line])
	can_advance_message = false # Disable advance until text is displayed

func _on_dialog_line_displayed():
	can_advance_message = true # Enable advance

func end_dialog():
	is_dialog_active = false
	can_advance_message = false	
	finalize_dialog_box()
	dialog_resource = null
	dialog_ended.emit()

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("advance_message") and is_dialog_active && can_advance_message):
		finalize_dialog_box()
		dialog_resource.current_line += 1
		show_dialog_line()
		
func finalize_dialog_box():
	if dialog_box:
		dialog_box.queue_free()
		
func restart_dialog_box():
	is_dialog_active = false
	can_advance_message = false
	finalize_dialog_box()
		
