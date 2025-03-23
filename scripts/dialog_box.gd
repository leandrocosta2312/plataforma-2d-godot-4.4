extends MarginContainer

const MAX_WIDTH : int = 255

@onready var text_label : Label = $label_margin/text_label
@onready var letter_timer : Timer = $letter_timer_display

var display_text : String = ""
var current_letter_index : int = 0

var normal_letter_delay : float = 0.07
var space_letter_delay : float = 0.05
var punctuation_letter_delay : float = 0.2

signal text_display_finished()


func start_display_text(text_to_display : String):
	display_text = text_to_display
	text_label.text = display_text
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	await resized
	if size.x > MAX_WIDTH:
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
	global_position.x -= size.x / 2
	global_position.y -= size.y + 16
	text_label.text = ""
	current_letter_index = 0
	_display_next_letter()

func _display_next_letter():
	if current_letter_index >= display_text.length():
		text_display_finished.emit()
		return
	text_label.text += display_text[current_letter_index]
	current_letter_index += 1
	var next_letter_delay : float = normal_letter_delay
	match display_text[current_letter_index - 1]:
		"!", "?", ",", ".":
			next_letter_delay = punctuation_letter_delay
		" ":
			next_letter_delay = space_letter_delay
	letter_timer.start(next_letter_delay)

func _on_letter_timer_display_timeout() -> void:
	_display_next_letter()
