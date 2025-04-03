extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $anim

signal on_transition_finished

func _ready() -> void:
	color_rect.visible = false
	anim.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		anim.play("fade_to_normal")
		on_transition_finished.emit()
	elif anim_name == "fade_to_normal": 
		color_rect.visible = false	
	
func transition():
	color_rect.visible = true
	anim.play("fade_to_black")
	
func transition_fade_in():
	color_rect.visible = true
	anim.play("fade_to_normal")
