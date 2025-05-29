extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var hp = 10
@export var movement_speed = 30
@export var experience = 3
@export var heal_drop_chance: float = 0.05
@export var magnet_drop_chance: float = 0.02

var is_dead = false

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var loot_base = get_tree().get_first_node_in_group("Loot")
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var hurt_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hit_collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var hit_flash: AnimationPlayer = $Sprite2D/HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var exp_to_drop = 3

var exp_drop = preload("res://Scenes/exp.tscn")
var heal_drop = preload("res://Scenes/heal_item.tscn")
var magnet_drop = preload("res://Scenes/magnet_item.tscn")

signal remove_from_array(object)

func _on_slime_defeated():
	print("Slime died")
	exp_to_drop = 6

func _on_stone_defeated():
	exp_to_drop += 6

func _physics_process(_delta: float):
	var direction = global_position.direction_to(player.global_position)
	if not is_dead:
		velocity = direction*movement_speed
		if direction.x > 0:
			sprite_2d.flip_h = false
		elif direction.x < 0:
			sprite_2d.flip_h = true
		move_and_slide()
	
func death():
	is_dead = true
	movement_speed = 0
	collision_shape_2d.disabled = true
	hurt_collision.call_deferred("set","disabled",true)
	hit_collision.call_deferred("set","disabled",true)
	hit_flash.play("hit_flash")
	animation_player.play("death")


func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	if hp <= 0:
		death()
	else:
		hit_flash.play("hit_flash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		emit_signal("remove_from_array", self)
		var new_exp = exp_drop.instantiate()
		new_exp.global_position = global_position
		new_exp.experience = exp_to_drop
		loot_base.call_deferred("add_child", new_exp)
		if heal_drop and randf() < heal_drop_chance:
			var new_special = heal_drop.instantiate()
			new_special.global_position = global_position
			loot_base.call_deferred("add_child", new_special)
		if magnet_drop and randf() < magnet_drop_chance:
			var new_special = magnet_drop.instantiate()
			new_special.global_position = global_position
			loot_base.call_deferred("add_child", new_special)
		queue_free()

func stop_moving():
	movement_speed = 0
	hit_collision.call_deferred("set","disabled",true)
	hurt_collision.call_deferred("set","disabled",true)
	collision_shape_2d.call_deferred("set","disabled",true)
