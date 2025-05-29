extends CharacterBody2D

var died = false
var dash_lock_in = false
var switch_skill = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var hp = 400
@export var movement_speed = 60
@export var experience = 1
@export var heal_drop_chance: float = 0.05
@export var magnet_drop_chance: float = 0.02

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var loot_base = get_tree().get_first_node_in_group("Loot")
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var hurt_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hit_collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var hit_flash: AnimationPlayer = $Sprite2D/HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dash_attack_cd: Timer = $DashAttackCD
@onready var attack_loading_time: Timer = $AttackLoadingTime
@onready var dash_collision: CollisionShape2D = $DashAttackHitBox/CollisionShape2D
@onready var fireball_timer: Timer = $FireballTimer
@onready var fireball_attack_timer: Timer = $FireballTimer/FireballAttackTimer

signal stone_defeated

var exp_drop = preload("res://Scenes/exp.tscn")
var heal_drop = preload("res://Scenes/heal_item.tscn")
var magnet_drop = preload("res://Scenes/magnet_item.tscn")
var treasure_drop = preload("res://Scenes/treasure.tscn")

var stone_fireball = preload("res://Scenes/stone_boss_bullet.tscn")

var initial_direction: Vector2 = Vector2.ZERO

var fireball_ammo = 0
var fireball_baseammo = 20
var fireball_attackspeed = 0.2
var fireball_level = 1

signal remove_from_array(object)

func _physics_process(_delta: float):
	if not died:
		if dash_lock_in:
			velocity = initial_direction * movement_speed
			if initial_direction.x > 0:
				sprite_2d.flip_h = false
			elif initial_direction.x < 0:
				sprite_2d.flip_h = true
			move_and_slide()
		else:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction*movement_speed
			if direction.x > 0:
				sprite_2d.flip_h = false
			elif direction.x < 0:
				sprite_2d.flip_h = true
		move_and_slide()
	
func death():
	movement_speed = 0
	collision_shape_2d.disabled = true
	hurt_collision.call_deferred("set","disabled",true)
	hit_collision.call_deferred("set","disabled",true)
	hit_flash.play("hit_flash")
	animation_player.play("death")


func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	if hp <= 0:
		died = true
		death()
	else:
		hit_flash.play("hit_flash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		emit_signal("stone_defeated")
		emit_signal("remove_from_array", self)
		for i in range(4):
			var exp_25 = exp_drop.instantiate()
			exp_25.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			exp_25.experience = 35
			loot_base.call_deferred("add_child", exp_25)
		for i in range(3):
			var exp_40 = exp_drop.instantiate()
			exp_40.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			exp_40.experience = 40
			loot_base.call_deferred("add_child", exp_40)
		var treasure_chest = treasure_drop.instantiate()
		treasure_chest.position = global_position
		loot_base.call_deferred("add_child", treasure_chest)
		queue_free()
	if anim_name == "transform_in":
		initial_direction = global_position.direction_to(player.global_position)
		dash_lock_in = true
		movement_speed = 150
		animation_player.play("launch_form")
		dash_collision.call_deferred("set","disabled",false)
		hit_collision.call_deferred("set","disabled",true)
	if anim_name == "launch_form":
		dash_collision.call_deferred("set","disabled",true)
		hit_collision.call_deferred("set","disabled",false)
		movement_speed = 0
		animation_player.play("transform_back")
	if anim_name == "transform_back":
		dash_lock_in = false
		animation_player.play("walking")
		movement_speed = 30
		switch_skill = !switch_skill
		dash_attack_cd.start()
	if anim_name == "charging":
		shooting_attack()
	if anim_name == "shooting":
		disable_shooting()
		animation_player.play("calm")
	if anim_name == "calm":
		animation_player.play("walking")
		movement_speed = 30
		switch_skill = !switch_skill
		dash_attack_cd.start()

func shooting_attack():
	animation_player.play("shooting")
	if fireball_level > 0:
		fireball_timer.wait_time = fireball_attackspeed
		if fireball_timer.is_stopped():
			fireball_timer.start()

func disable_shooting():
	fireball_attack_timer.stop()
	fireball_timer.stop()
	

func _on_dash_attack_cd_timeout() -> void:
	if !died:
		movement_speed = 0
		attack_loading_time.start()

func _on_attack_loading_time_timeout() -> void:
	if switch_skill:
		animation_player.play("transform_in")
	else:
		animation_player.play("charging")


func _on_fireball_timer_timeout() -> void:
	fireball_ammo += fireball_baseammo
	fireball_attack_timer.start()

func _on_fireball_attack_timer_timeout() -> void:
	if fireball_ammo > 0:
		var fireball_position = position
		fireball_position.y -= 26
		var fireball_attack = stone_fireball.instantiate()
		fireball_attack.position = fireball_position
		fireball_attack.target = player.global_position
		fireball_attack.level = fireball_level
		get_tree().current_scene.add_child(fireball_attack)
		fireball_ammo -= 1
		if fireball_ammo > 0:
			fireball_attack_timer.start()
		else:
			fireball_attack_timer.stop()
