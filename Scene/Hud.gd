extends CanvasLayer

@onready var time_label: Label = $TimeLabel
@onready var kills_label: Label = $KillsLabel

func _ready() -> void:
	Global.start_run()

func _process(_delta: float) -> void:
	var t = int(ceil(maxf(Global.time_left, 0.0)))
	var minutes = t / 60
	var seconds = t % 60
	if Global.endless:
		time_label.text = "Final Wave - Survive!"
	elif Global.phase == Global.Phase.BREAK:
		time_label.text = "Wave %d starts in %02d:%02d" % [Global.cur_level + 1, minutes, seconds]
	else:
		time_label.text = "Wave %d ends in %02d:%02d" % [Global.cur_level, minutes, seconds]
	kills_label.text = "Kills: %d" % Global.kill_count
	
