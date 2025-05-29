extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func collect():
	collision_shape_2d.call_deferred("set","disabled",true)
	sprite_2d.visible = false
	queue_free()
