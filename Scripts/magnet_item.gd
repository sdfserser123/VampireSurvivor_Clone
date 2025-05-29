extends Area2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("Player")

func collect():
	collision_shape_2d.call_deferred("set","disabled",true)
	sprite_2d.visible = false
	var loot_nodes = get_tree().get_nodes_in_group("Loot")
	for loot in loot_nodes:
		if loot.has_method("set_target"):
			loot.set_target(player, get_physics_process_delta_time())
	queue_free()
