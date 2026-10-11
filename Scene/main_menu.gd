extends Node2D

@onready var start_btn: Button = $Menu/Start/Button
@onready var exit_btn: Button = $Menu/Exit/Button

func _ready() -> void:
	get_tree().paused = false
	Global.is_running = false
	start_btn.pressed.connect(_on_start)
	exit_btn.pressed.connect(_on_exit)

func _on_start() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Game_Scene.tscn")

func _on_exit() -> void:
	get_tree().quit()
