extends Camera2D

@export var player_path: NodePath  # Caminho inicial do Player
@export var alternate_target_path: NodePath  # Caminho para o segundo alvo
@export var switch_key: String = "space"  # Tecla para alternar entre alvos

var current_target: Node = null  # Referência ao alvo atual

func _ready() -> void:
	current_target = get_node(player_path)
	position = current_target.position  # Ajusta a posição inicial da câmera

func _process(delta: float) -> void:
	if current_target:
		global_position = current_target.global_position		

func switch_target() -> void:
	# Alterna entre o player e o alvo alternativo
	if current_target == get_node(player_path):
		current_target = get_node(alternate_target_path)
	else:
		current_target = get_node(player_path)
