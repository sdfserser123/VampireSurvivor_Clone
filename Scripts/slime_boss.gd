extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var hp = 250
@export var movement_speed = 30
@export var experience = 1
@export var heal_drop_chance: float = 0.05
@export var magnet_drop_chance: float = 0.02

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var loot_base = get_tree().get_first_node_in_group("Loot")
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var hurt_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hit_collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var slam_effect: Sprite2D = $SlamEffect
@onready var slam_anim: AnimationPlayer = $SlamEffect/AnimationPlayer
@onready var hit_flash: AnimationPlayer = $Sprite2D/HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ultimate_cd: Timer = $UltimateCD
@onready var ultimate_timer: Timer = $UltimateTimer
@onready var finish_ultimate_timer: Timer = $FinishUltimateTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var ultimate_collision: CollisionShape2D = $UltimateHitBox/CollisionShape2D

@onready var hurt_box: Area2D = $HurtBox
@onready var hit_box: Area2D = $HitBox

var exp_drop = preload("res://Scenes/exp.tscn")
var heal_drop = preload("res://Scenes/heal_item.tscn")
var magnet_drop = preload("res://Scenes/magnet_item.tscn")
var treasure_drop = preload("res://Scenes/treasure.tscn")

signal slime_defeated

signal remove_from_array(object)

func _ready() -> void:
	slam_effect.visible = false
	ultimate_collision.disabled = true
	ultimate_timer.timeout.connect(_on_ultimate_timer_timeout)
	finish_ultimate_timer.timeout.connect(_on_finish_ultimate_timer_timeout)
	recovery_timer.timeout.connect(_on_recovery_timer_timeout)

func _physics_process(_delta: float):
	var target_position = player.global_position
	target_position.y -= 30
	var direction = global_position.direction_to(target_position)
	velocity = direction*movement_speed
	move_and_slide()
	
func death():
	movement_speed = 0
	collision_shape_2d.disabled = true
	hurt_collision.call_deferred("set","disabled",true)
	hit_collision.call_deferred("set","disabled",true)
	hit_flash.play("hit_flash")
	animation_player.play("death")

func ultimate_move():
	if ultimate_cd.is_stopped():
		ultimate_cd.start()

func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	if hp <= 0:
		death()
	else:
		hit_flash.play("hit_flash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		emit_signal("remove_from_array", self)
		emit_signal("slime_defeated")
		for i in range(2):
			var exp_25 = exp_drop.instantiate()
			exp_25.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
			exp_25.experience = 25
			loot_base.call_deferred("add_child", exp_25)

		var exp_40 = exp_drop.instantiate()
		exp_40.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		exp_40.experience = 40
		loot_base.call_deferred("add_child", exp_40)
		var treasure_chest = treasure_drop.instantiate()
		treasure_chest.position = global_position
		loot_base.call_deferred("add_child", treasure_chest)
		queue_free()
	if anim_name == "charging":
		animation_player.play("jump")
		hurt_collision.call_deferred("set","disabled",true)
		hit_collision.call_deferred("set","disabled",true)
	if anim_name == "jump":
		movement_speed = 250
		sprite_2d.visible = false
		ultimate_timer.start()
		print("Jump xong, gọi start ultimate_timer")
	if anim_name == "dropping":
		animation_player.play("walking")
		recovery_timer.start()
		hurt_collision.call_deferred("set","disabled",false)
		hit_collision.call_deferred("set","disabled",false)
		ultimate_collision.call_deferred("set","disabled",true)
		

func _on_ultimate_cd_timeout() -> void:
	ultimate_cd.stop()
	movement_speed = 0
	animation_player.play("charging")


func _on_ultimate_timer_timeout() -> void:
	movement_speed = 0
	finish_ultimate_timer.start()


func _on_finish_ultimate_timer_timeout() -> void:
	print("Đã chạy _on_ultimate_timer_timeout")
	sprite_2d.visible = true
	animation_player.play("dropping")
	slam_anim.play("slam")


func _on_recovery_timer_timeout() -> void:
	print("Đã chạy _on_recovery_timer_timeout")
	movement_speed = 30
	ultimate_cd.start()
