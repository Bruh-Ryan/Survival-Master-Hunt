extends CharacterBody2D

var bullet_assest = preload("res://Scene/Guns/Bullet.tscn")
@onready var aim_assest : AnimatedSprite2D = $Aim_Sprite
@onready var animation_ply : AnimatedSprite2D = $PlayerSprite
@onready var Ammo_Sprite : AnimatedSprite2D = $Ammo_Sprite
@onready var HLT_SPRITES: AnimatedSprite2D = $Health_Sprite

@export var SPEED = 50
var CAN_FIRE = true
var AIM_DISTANCE = 50
@export var AMMO = Global.MAX_AM_SIZE
var IS_IMMUNE = false



func _ready():
	add_to_group("Player")
	Global.player_immunity.connect(set_immnue)
	Global.set_player_refference(self)
	update_health_sprite()

func _physics_process(delta):
	player_movement()
	aim_weapons()

func player_movement():
	# Built-in velocity is used, no local variable
	var direction := Input.get_vector("left", "right", "forward", "back")
	velocity = direction * SPEED
	update_animation(direction)

	if Input.is_action_pressed("fire") and CAN_FIRE:
		fire()

	move_and_slide()

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		animation_ply.stop()   # or play("idle") if you have one
		return

	# Horizontal wins when moving sideways, otherwise vertical
	if direction.x != 0:
		animation_ply.flip_h = direction.x < 0
		animation_ply.play("walk_right_left")
	elif direction.y < 0:
		animation_ply.flip_h = false
		animation_ply.play("walk_forward")
	else:
		animation_ply.flip_h = false
		animation_ply.play("walk_back")
	
func fire():
	if AMMO>0:
		CAN_FIRE = false
		var direction = (get_global_mouse_position() - global_position).normalized()
		var bullet = bullet_assest.instantiate()
		
		get_tree().current_scene.add_child(bullet)
		fire_animation()
		bullet.global_position = global_position + direction * 10
		bullet.rotation = direction.angle()
		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)
		
		await get_tree().create_timer(1).timeout
		CAN_FIRE = true

## AMMO ------------------------
func fire_animation():
	AMMO-=1
	var frame_count = Ammo_Sprite.sprite_frames.get_frame_count("Ammo_Stock")
	var ratio = float(AMMO) / Global.CUR_AM_SIZE
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	Ammo_Sprite.frame = clamp(frame_index, 0, frame_count - 1)
	
func aim_weapons():
	var direction = (get_global_mouse_position() - global_position).normalized()
	aim_assest.global_position = global_position + direction * AIM_DISTANCE

## HEALTH ------------------------
func set_health(value: int):
	if not IS_IMMUNE:
		Global.CUR_PLY_HLT = clamp(value, 0, Global.MAX_HLT)
		print("PLY Hlt", Global.CUR_PLY_HLT)
		update_health_sprite()
		if Global.CUR_PLY_HLT == 0:
			die()

func update_health_sprite():
	var frame_count = HLT_SPRITES.sprite_frames.get_frame_count("Health")
	var ratio = float(Global.CUR_PLY_HLT) / Global.MAX_HLT
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	HLT_SPRITES.frame = clamp(frame_index, 0, frame_count - 1)

func die():
	queue_free()

func set_immnue(time: float):
	if IS_IMMUNE:
		return
	IS_IMMUNE = true
	await get_tree().create_timer(time).timeout
	IS_IMMUNE = false
