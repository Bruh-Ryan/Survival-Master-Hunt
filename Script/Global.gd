extends Node

signal player_immunity(time : float)
signal phase_changed(phase)
signal wave_changed(level)
signal game_over

var player_node = null
var inventory_size = 1
var inventory_max = 6
var score = 0        # total score
var kill_count = 0    # number of enemies killed
var run_time: float = 0.0
var is_running: bool = false
var was_running := false
var cur_level = 1
var MAX_LVL = 5

const LEVEL_TIMES := [60.0, 90.0, 120.0, 120.0, 360.0]
const BREAK_TIME := 15.0
enum Phase { WAVE, BREAK }
var phase: int = Phase.WAVE
var time_left: float = LEVEL_TIMES[0]
var endless := false

var CUR_PLY_HLT = 3
var MAX_HLT = 5
var CUR_AM_SIZE = 9
var MAX_AM_SIZE = 15

func _process(delta: float) -> void:
	if is_running:
		run_time += delta
	if not is_running or endless:
		return
	time_left -= delta
	if time_left <= 0.0:
		_advance()

func _advance() -> void:
	if phase == Phase.WAVE and cur_level < MAX_LVL:
		phase = Phase.BREAK
		time_left = BREAK_TIME
		phase_changed.emit(phase)
	elif phase == Phase.BREAK:
		cur_level += 1
		phase = Phase.WAVE
		time_left = LEVEL_TIMES[cur_level - 1]
		wave_changed.emit(cur_level)
		phase_changed.emit(phase)
	elif phase == Phase.WAVE and cur_level == MAX_LVL:
		endless = true
		time_left = 0.0

func start_run():
	is_running = true
	run_time = 0.0
	kill_count = 0
	score = 0
	cur_level = 1
	phase = Phase.WAVE
	time_left = LEVEL_TIMES[0]
	endless = false
	phase_changed.emit(phase)
	wave_changed.emit(cur_level)
func pause_run():
	was_running = is_running
	is_running = false

func resume_run():
	is_running = was_running


func set_player_refference(player):
	player_node = player

func take_damage(amount := 1) -> void:
	if not is_instance_valid(player_node):
		return
	if player_node.IS_IMMUNE:
		return
	CUR_PLY_HLT = clampi(CUR_PLY_HLT - amount, 0, MAX_HLT)
	player_node.update_health_sprite()
	player_immunity.emit(4.0)
	if CUR_PLY_HLT <= 0:
		show_death_menu()
		player_node.die()

func register_kill():
	kill_count += 1
	score += 10
	
func show_death_menu():
	is_running = false
	game_over.emit()
