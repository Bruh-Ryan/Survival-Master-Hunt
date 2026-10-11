extends CharacterBody2D

var wander_speed = 30
var attack_speed = 40
var follow_player = false
var player_ref = null
var health = 100
@export var tk_dmg = 20
var wander_velocity = Vector2.ZERO
var player_in_contact = false
@onready var wander_timer = $WanderTimer  # a Timer node, set wait_time in editor


func _ready():
	add_to_group("Enemy")
	randomize()
	wander_timer.timeout.connect(_pick_new_wander_direction)
	_pick_new_wander_direction()

func _physics_process(delta):
	if follow_player and is_instance_valid(player_ref):
		var direction = (player_ref.global_position - global_position).normalized()
		velocity = direction * attack_speed
		move_and_slide()
	elif follow_player:
		follow_player = false
		player_ref = null
		velocity = wander_velocity
		move_and_slide()
	else:
		velocity = wander_velocity
		move_and_slide()

	if player_in_contact:
		Global.take_damage()

func _pick_new_wander_direction():
	var velocity_dir = Vector2.ZERO
	velocity_dir.x = 1 if randf() > 0.5 else -1
	velocity_dir.y = 1 if randf() > 0.5 else -1
	wander_velocity = velocity_dir.normalized() * wander_speed

func _on_detect_sphere_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		follow_player=true 
		player_ref = body

func _on_health_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullets"):
		health-=tk_dmg
		print("damage")
		if health<10:
			die()
	if body.is_in_group("Player"):
		player_in_contact = true

func _on_health_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_contact = false
		
func die():
	Global.register_kill()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(queue_free)
