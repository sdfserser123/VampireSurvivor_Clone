extends Area2D

@export var experience = 1

var spr_green = preload("res://Texture/16x16 Beginner Pixel Art Item Pack/Items/emerald.png")
var spr_blue = preload("res://Texture/16x16 Beginner Pixel Art Item Pack/Items/sapphire.png")
var spr_red = preload("res://Texture/16x16 Beginner Pixel Art Item Pack/Items/ruby.png")

var target = null
var speed = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite_2d.texture = spr_blue
	elif experience >= 25:
		sprite_2d.texture = spr_red

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta

func collect():
	collision_shape_2d.call_deferred("set","disabled",true)
	sprite_2d.visible = false
	queue_free()
	return experience

func set_target(player, delta):
	target = player
	speed += 5*delta
