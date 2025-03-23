extends Control

@onready var coins_text: Label = $container/coins_container/coins_text as Label
@onready var score_text: Label = $container/score_container/score_text as Label
@onready var life_text: Label = $container/life_container/life_text as Label
@onready var clock_timer: Timer = $container/clock_timer as Timer
@onready var timer_text: Label = $container/timer_container/timer_text
@export_range(0, 5) var default_minutes = 1
@export_range(0, 59) var default_seconds = 0

var minutes = 0
var seconds = 0

signal time_is_up()

func _ready() -> void:
	minutes = default_minutes
	seconds = default_seconds
	getStats()
	reset_clock_timer()	

func _process(delta: float) -> void:
	getStats()
	if (minutes == 0 && seconds == 0):
		time_is_up.emit()
	
	
func getStats():
	coins_text.text = str("%04d" % GlobalManager.coins)
	score_text.text = str("%06d" % GlobalManager.score)
	life_text.text = str(GlobalManager.lifes)
	timer_text.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)


func _on_clock_timer_timeout() -> void:
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1
	
func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds
