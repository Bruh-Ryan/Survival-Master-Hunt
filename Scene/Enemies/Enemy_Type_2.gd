extends CharacterBody2D

@onready var wander_timer = $WanderTimer
@onready var animation = $Type_2

var current_zone 

var SPEED = 10
var ENEMY_SPEED = 10
var FOLLOW_PLY = false
var PLY_REF = null
var attack_player = false

var is_jumping = false
var jump_target = Vector2.ZERO
var jump_duration = 0.8
var jump_height = 20
var NO_WALLS_COLLIDE = false

var HEALTH = 100
@export var tk_dmg = 50
var touching_player := false

func _ready():
	add_to_group("Enemy")
	$Impact_Zone.body_entered.connect(_on_impact_zone_body_entered)
	$Impact_Zone.body_exited.connect(_on_impact_zone_body_exited) # ADDED: touch end
	for zone in get_tree().get_nodes_in_group("Zone"):
		zone.broadcast_player_zone.connect(_on_zone_update)

	
func _physics_process(delta: float) -> void:
	if FOLLOW_PLY and not is_instance_valid(PLY_REF):
		FOLLOW_PLY = false
		PLY_REF = null
		touching_player = false
	if FOLLOW_PLY and PLY_REF and not is_jumping:
		start_jump(PLY_REF.global_position)
	if not is_jumping and !FOLLOW_PLY:
		_on_wander_timeout()
	move_and_slide()
	if touching_player:
		Global.take_damage()

func _on_wander_timeout():
	if is_jumping or FOLLOW_PLY:
		return                       # busy chasing → skip this tick
	var target = _pick_free_target()
	if target != global_position:
		start_jump(target)           # existing 0.8s arc hop, no teleport

func _pick_free_target() -> Vector2:
	for i in 8:                      # walls detected → try a different path
		var dist = randf_range(45, 50)
		var target = global_position + Vector2.from_angle(randf() * TAU) * dist
		var q = PhysicsRayQueryParameters2D.create(global_position, target)
		q.exclude = [get_rid()]
		if get_world_2d().direct_space_state.intersect_ray(q).is_empty():
			return target            # clear path
	return global_position
	
func _on_zone_update(zone_name: String, is_inside: bool):
	if zone_name == current_zone:
		attack_player = true
	if current_zone == null:
		pass
	
func start_jump(target_pos: Vector2):
	is_jumping = true
	
	jump_target = target_pos
	var start_pos = global_position
	var tween = create_tween()
	tween.set_parallel(true)

	# horizontal movement: straight line from start to target
	tween.tween_property(self, "global_position", jump_target, jump_duration)

	# fake vertical arc using a Sprite2D/AnimatedSprite2D offset, not position itself
	tween.tween_method(_update_jump_arc, 0.0, 1.0, jump_duration)

	tween.chain().tween_callback(_on_jump_finished)
	
func _update_jump_arc(t: float) -> void:
	# parabola: 0 at t=0, peak at t=0.5, 0 at t=1
	var arc = -4 * jump_height * (t - 0.5) * (t - 0.5) + jump_height
	animation.position.y = -arc  # negative = visually "up"
	
func _on_jump_finished() -> void:
	animation.position.y = 0
	is_jumping = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		FOLLOW_PLY = true
		PLY_REF = body
		attack_player = true
		animation.play("jump")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		FOLLOW_PLY = false
		PLY_REF = null
		attack_player = false
		animation.play("default")


func _on_impact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullets"):
		HEALTH -= tk_dmg
		body.queue_free()
		if HEALTH < 10:
			Global.register_kill()
			queue_free()
	elif body.is_in_group("Player"): # ADDED: touch start (brutal contact)
		touching_player = true

func _on_impact_zone_body_exited(body: Node2D) -> void: # ADDED: touch end
	if body.is_in_group("Player"):
		touching_player = false

func _on_range_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Zone1":
		current_zone = area.name

func _on_range_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Zone1":
		current_zone = ""
