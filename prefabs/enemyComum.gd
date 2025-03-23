extends EnemyBase

func _ready_base():
	anim.animation_finished.connect(animation_finished_grounded)
	anim.animation_started.connect(animation_started_grounded)
