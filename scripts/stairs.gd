extends Node2D

const signal_name = "show_stairs"

@export var emitter_node_path: NodePath  # Define como exportável para configurar no editor

func _ready() -> void:
	var emitter_node = get_node(emitter_node_path)
	if emitter_node && emitter_node.has_signal(signal_name):
		emitter_node.connect(signal_name, show_up, ConnectFlags.CONNECT_DEFERRED)

func show_up():
	for block in get_children():
		var anim = block.get_node("anim") as AnimationPlayer
		anim.play("grow")
		await anim.animation_finished
		
