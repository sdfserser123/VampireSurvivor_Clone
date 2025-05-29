extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var player = get_tree().get_first_node_in_group("Player")

var level = 1
var hp = 1
var speed = 100
var bullet_dmg = 5
var damage = 0


func _ready():
	match level:
		1:
			bullet_dmg = 2
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		2:
			bullet_dmg = 2
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		3:
			bullet_dmg = 5
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		4:
			bullet_dmg = 5
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		5:
			bullet_dmg = 5
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)

func _process(delta: float) -> void:
	pass
