extends CharacterBody2D

var skill = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var hp = 600
@export var movement_speed = 70
@export var experience = 1

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var loot_base = get_tree().get_first_node_in_group("Loot")
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var hurt_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hit_collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var hit_flash: AnimationPlayer = $Sprite2D/HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var skill_cd: Timer = $SkillCd
@onready var startup_timer: Timer = $StartupTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var attacking_timer: Timer = $AttackingTimer
@onready var infernal_timer: Timer = $Attack/InfernalTimer
@onready var infernal_attack_timer: Timer = $Attack/InfernalTimer/InfernalAttackTimer
@onready var infernalball_timer: Timer = $Attack/InfernalBallTimer
@onready var infernalball_attack_timer: Timer = $Attack/InfernalBallTimer/InfernalballAttackTimer
@onready var skull_timer: Timer = $Attack/SkullTimer
@onready var skull_attack_timer: Timer = $Attack/SkullTimer/SkullAttackTimer
@onready var wait_timer: Timer = $WaitTimer
@onready var dying_timer: Timer = $DyingTimer
@onready var explosing_wait_timer: Timer = $ExplosingWaitTimer
@onready var explosing_timer: Timer = $ExplosingWaitTimer/ExplosingTimer

var exp_drop = preload("res://Scenes/exp.tscn")
var cake = preload("res://Scenes/cake.tscn")

var ie_attack = preload("res://Scenes/infernal_explosion.tscn")
var ie_ball = preload("res://Scenes/infernal_bullet.tscn")
var skull = preload("res://Scenes/skull_attack.tscn")
var explosion = preload("res://Scenes/explosion.tscn")

signal remove_from_array(object)

var infernal_ammo = 0
var infernal_baseammo = 1
var infernal_attackspeed = 0.5
var infernal_level = 1

var infernalball_ammo = 0
var infernalball_baseammo = 20
var infernalball_attackspeed = 0.2
var infernalball_level = 1

var skull_ammo = 0
var skull_baseammo = 1
var skull_attackspeed = 0.2
var skull_level = 1

var explosion_num = 0
var explosion_basenum = 10

signal final_boss_defeated()
signal final_boss_dying()

var is_dead = false

func _physics_process(_delta: float):
	if not is_dead:
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
		is_dead = true
		dying()
	else:
		hit_flash.play("hit_flash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		emit_signal("remove_from_array", self)
		var new_exp = exp_drop.instantiate()
		new_exp.global_position = global_position
		new_exp.experience
		loot_base.call_deferred("add_child", new_exp)
		emit_signal("final_boss_defeated")
		var all_enemy = get_tree().get_nodes_in_group("Enemy")
		for each_enemy in all_enemy:
			each_enemy.stop_moving()
		var the_prize = cake.instantiate()
		the_prize.position = global_position
		loot_base.call_deferred("add_child", the_prize)
		queue_free()
	if anim_name == "skill_1":
		animation_player.play("walking")
		recovery_timer.start()
		attacking_timer.start()
	if anim_name == "skill_2_startup":
		print("Startup animation finished → shooting_ball()")
		animation_player.play("skill_2_active")
		shooting_ball()
	if anim_name == "skill_2_active":
		attack_stop()
		animation_player.play("skill_2_recovery")
	if anim_name == "skill_2_recovery":
		animation_player.play("walking")
		recovery_timer.start()
	if anim_name == "skill_3":
		animation_player.play("walking")
		recovery_timer.start()

func bombaAttack():
	animation_player.play("skill_1")
	if infernal_level > 0:
		infernal_timer.wait_time = infernal_attackspeed
		if infernal_timer.is_stopped():
			infernal_timer.start()

func shooting_ball():
	animation_player.play("shooting")
	if infernalball_level > 0:
		infernalball_timer.wait_time = infernalball_attackspeed
		if infernalball_timer.is_stopped():
			infernalball_timer.start()

func skull_spell():
	if skull_level > 0:
		print("Calling skull_spell(), skull_level = ", skull_level)
		skull_timer.wait_time = skull_attackspeed
		if skull_timer.is_stopped():
			skull_timer.start()

func attack_stop():
	infernal_timer.stop()
	infernal_attack_timer.stop()
	
	infernalball_attack_timer.stop()
	infernalball_timer.stop()
	
	skull_attack_timer.stop()
	skull_timer.stop()

func _on_skill_cd_timeout() -> void:
	movement_speed = 0
	skill = randi_range(1, 3)
	startup_timer.start()
	
func _on_startup_timer_timeout() -> void:
	match skill:
		1:
			bombaAttack()
		2:
			animation_player.play("skill_2_startup")
		3:
			skull_spell()
			animation_player.play("skill_3")

func _on_recovery_timer_timeout() -> void:
	movement_speed = 40
	if skill != 3:
		skill_cd.start()
	else:
		wait_timer.start()

func _on_attacking_timer_timeout() -> void:
	attack_stop()

func _on_infernal_timer_timeout() -> void:
	infernal_ammo += infernal_baseammo
	infernal_attack_timer.start()

func _on_infernal_attack_timer_timeout() -> void:
	if infernal_ammo > 0:
		for i in range(3):
			var infernal_attack = ie_attack.instantiate()
			infernal_attack.position = player.global_position
			get_tree().current_scene.add_child(infernal_attack)
		infernal_ammo -= 1
		if infernal_ammo > 0:
			infernal_attack_timer.start()
		else:
			infernal_attack_timer.stop()

func _on_infernal_ball_timer_timeout() -> void:
	infernalball_ammo += infernalball_baseammo
	infernalball_attack_timer.start()

func _on_infernalball_attack_timer_timeout() -> void:
	if infernalball_ammo > 0:
		var origin_pos = position
		origin_pos.y -= 43
		if sprite_2d.flip_h == false:
			origin_pos.x += 18
		else:
			origin_pos.x -= 17
		var base_direction = (player.global_position - origin_pos).normalized()

		var angle_offset = deg_to_rad(30)
		var left_direction = base_direction.rotated(-angle_offset)
		var right_direction = base_direction.rotated(angle_offset)

		var directions = [base_direction, left_direction, right_direction]

		for dir in directions:
			var infernalball = ie_ball.instantiate()
			infernalball.position = origin_pos
			infernalball.target = origin_pos + dir * 1000 
			infernalball.level = infernalball_level
			get_tree().current_scene.add_child(infernalball)

		infernalball_ammo -= 1
		if infernalball_ammo > 0:
			infernalball_attack_timer.start()
		else:
			infernalball_attack_timer.stop()


func _on_skull_timer_timeout() -> void:
	skull_ammo += skull_baseammo
	skull_attack_timer.start()

func _on_skull_attack_timer_timeout() -> void:
	if skull_ammo > 0:
		for i in range(3):
			var skull_attack = skull.instantiate()
			
			# Offset một chút để không chồng lên nhau
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
			skull_attack.position = player.global_position + offset
			
			get_tree().current_scene.add_child(skull_attack)
		
		skull_ammo -= 1
		if skull_ammo > 0:
			skull_attack_timer.start()
		else:
			skull_attack_timer.stop()

func dying():
	emit_signal("final_boss_dying")
	skill_cd.stop()
	movement_speed = 0
	hit_collision.call_deferred("set","disabled",true)
	hurt_collision.call_deferred("set","disabled",true)
	dying_timer.start()
	explosing_wait_timer.start()

func _on_wait_timer_timeout() -> void:
	skill_cd.start()
	

func _on_dying_timer_timeout() -> void:
	death()
	
func _on_explosing_wait_timer_timeout() -> void:
	explosing_wait_timer.wait_time = 5
	explosion_num += explosion_basenum
	explosing_timer.start()

func _on_explosing_timer_timeout() -> void:
	if explosion_num > 0:
		var explosing_effect = explosion.instantiate()
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		explosing_effect.position = global_position + offset
		get_tree().current_scene.add_child(explosing_effect)
		explosion_num -= 1
		if explosion_num > 0:
			explosing_timer.start()
		else:
			explosing_timer.stop()
