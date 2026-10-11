extends Node2D
@onready var spawn_zones = $Spawn_Zones
@onready var menu : CanvasLayer = $Main_Menu
@onready var pause_menu: ColorRect = $Main_Menu/Pause_Menu
@onready var pause_title: Label = $Main_Menu/Pause_Menu/Pause_Ply_Button

var is_menu_open := false

var spawn_timer: Timer
@export var enemy_scenes: Array[PackedScene] = []
var max_enemies = 10
var spawn_intervals = 5
var cur_enemies = 0
var start_after = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enemy_scenes.is_empty():
		enemy_scenes = [
			preload("res://Scene/Enemies/Enemy_Type_1.tscn"),
			preload("res://Scene/Enemies/Enemy_Type_2.tscn"),
		]
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_intervals
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	Global.phase_changed.connect(_on_phase_changed)
	Global.game_over.connect(_on_game_over)
	add_child(spawn_timer)
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.hide()
	$Main_Menu/Pause_Menu/Pause_Ply_Button/Button.pressed.connect(_on_resume)
	$Main_Menu/Pause_Menu/Exit_Button/Button.pressed.connect(_on_restart)
	
	await get_tree().create_timer(start_after).timeout
	if Global.phase == Global.Phase.WAVE and Global.is_running:
		spawn_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_menu_open:
			_on_resume()
		else:
			open_pause_menu()

func open_pause_menu():
	if is_menu_open:
		return
	is_menu_open = true
	pause_title.text = "Paused"
	$Main_Menu/Pause_Menu/Pause_Ply_Button/Button.show()
	pause_menu.show()
	Global.pause_run()
	spawn_timer.stop()
	get_tree().paused = true

func _on_resume():
	if not is_menu_open:
		return
	if pause_title.text == "YOU DIED":
		return
	is_menu_open = false
	pause_menu.hide()
	get_tree().paused = false
	Global.resume_run()
	if Global.phase == Global.Phase.WAVE and Global.is_running:
		spawn_timer.start()

func _on_game_over():
	if is_menu_open:
		return
	is_menu_open = true
	pause_title.text = "YOU DIED"
	$Main_Menu/Pause_Menu/Pause_Ply_Button/Button.hide()
	pause_menu.show()
	spawn_timer.stop()
	get_tree().paused = true

func _on_restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func _on_spawn_timer_timeout():
	if cur_enemies >= max_enemies:
		return
	spawn_random_enemy()

func _on_phase_changed(phase: int) -> void:
	if phase == Global.Phase.BREAK:
		spawn_timer.stop()
		return
	if not Global.is_running:
		spawn_timer.stop()
		return
	if not spawn_timer.is_stopped():
		spawn_timer.stop()
	spawn_timer.start()
	
func spawn_random_enemy():
	var markers = spawn_zones.get_children()
	if markers.is_empty():
		return
	var lvl: int = Global.cur_level
	var want: int = (lvl + 1) if lvl <= 3 else 4
	var active_count: int = mini(want, markers.size())
	var marker = markers[randi() % active_count]
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()
	enemy.global_position = marker.global_position
	add_child(enemy)
	cur_enemies += 1
	enemy.tree_exited.connect(func(): cur_enemies = maxi(0, cur_enemies - 1))
