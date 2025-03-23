extends EnemyBase

func _ready_base():
	anim.animation_finished.connect(animation_finished_grounded)
