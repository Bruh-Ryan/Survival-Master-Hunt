extends Area2D

const RED_FRAME := 0 # ADDED: verify by scrubbing ALLOW frames (swap if green is 0)
const GREEN_FRAME := 1 # ADDED: author's exit code treated 1 as the on-state

var HEALTH = 100
var enemies_inside := 0 # ADDED: needed for the player+enemy → red rule
var player_inside := false # ADDED

signal broadcast_furniture_status(is_attacked: bool, name_obj : String)
signal broadcast_player_entry(is_allowed: bool)
@onready var SHOW_FURNITURE_HEALTH : AnimatedSprite2D = $"../Health"
@onready var DAMAGE_TIME : Timer = $"../Timer"  # placed in editor, wait_time=5, one_shot=false
@onready var ALLOWED : = $"../ALLOW"

func _ready() -> void:
	add_to_group("Destroy_Zones")
	SHOW_FURNITURE_HEALTH.hide()
	DAMAGE_TIME.timeout.connect(_on_damage_timer_timeout)
	# REMOVED: body_entered/exited connects — tscn already wires them (was double-connect error)
	_update_light() # ADDED: boot state (full health → green)

func _on_body_entered_enemy(body: Node2D) -> void:
	if body.is_in_group("Enemy") and HEALTH != 0:
		enemies_inside += 1 # ADDED: track for the light rule
		broadcast_furniture_status.emit(body, true)
		SHOW_FURNITURE_HEALTH.show()
		DAMAGE_TIME.start()
	elif body.is_in_group("Player"):
		player_inside = true # ADDED: track for the light rule
		broadcast_furniture_status.emit(body, true)
		# show_menu() # COMMENTED OUT: dormant until fridge-loot step
	_update_light() # ADDED
	# consider removing the confusing else-branch entirely (see below)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemies_inside = maxi(0, enemies_inside - 1) # ADDED (freed enemy auto-fires exit too)
		broadcast_furniture_status.emit(body, false)
		if enemies_inside == 0: # CHANGED: was hide/stop on ANY exit (wrong with 2+ enemies)
			SHOW_FURNITURE_HEALTH.hide()
			DAMAGE_TIME.stop()
	elif body.is_in_group("Player"):
		player_inside = false # ADDED
		broadcast_furniture_status.emit(body, false)
		broadcast_player_entry.emit(false) # ADDED: left the zone → E prints nothing (proximity gate)
	_update_light() # ADDED: replaces broken frame 0/1 lines below (deleted)
	
func _on_damage_timer_timeout() -> void:
	HEALTH -= 20
	HEALTH = clamp(HEALTH, 0, 100)
	_update_health_sprite()
	if HEALTH <= 0:
		# no single "body" here since this is time-based, not a body event
		DAMAGE_TIME.stop()
	_update_light() # ADDED: smashed → red

func _update_health_sprite() -> void:
	var frame_count = SHOW_FURNITURE_HEALTH.sprite_frames.get_frame_count("Health")
	var ratio = float(HEALTH) / 100.0
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	SHOW_FURNITURE_HEALTH.frame = clamp(frame_index, 0, frame_count - 1)


func _update_light() -> void: # ADDED: the single rule — green iff alive and not contested
	var green: bool = HEALTH > 0 and not (player_inside and enemies_inside > 0) # CHANGED: explicit bool (HEALTH untyped, := can't infer)
	ALLOWED.frame = GREEN_FRAME if green else RED_FRAME
	if player_inside: # ADDED: emit only while player present (exit sends its own false above)
		broadcast_player_entry.emit(green)

func is_interaction_allowed() -> bool: # ADDED: future fridge-loot reads this
	return HEALTH > 0 and not (player_inside and enemies_inside > 0)

# func show_menu(): # COMMENTED OUT: dormant until fridge-loot step
# 	get_tree().paused
# 	if ALLOWED and HEALTH>0 and player_inside:
# 		pass
