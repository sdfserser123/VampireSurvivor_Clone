extends Area2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("Player")

func collect():
	collision_shape_2d.call_deferred("set","disabled",true)
	queue_free()
