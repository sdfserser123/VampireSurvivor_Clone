extends Area2D

var level = 1
var hp = 1
var speed = 100
var bullet_dmg = 5
var damage = 0
var knock_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("Player")
signal remove_from_array(object)
func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(0)
	match level:
		1:
			hp = 1
			speed = 100
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
			knock_amount = 100
			attack_size = 1.0
		2:
			hp = 1
			speed = 100
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
			knock_amount = 100
			attack_size = 1.0
		3:
			hp = 1
			speed = 100
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
			knock_amount = 100
			attack_size = 1.0
		4:
			hp = 2
			speed = 100
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
			knock_amount = 100
			attack_size = 1.0
		5:
			hp = 2
			speed = 100
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
			knock_amount = 100
			attack_size = 1.0
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	

func _physics_process(delta: float) -> void:
	position += angle*speed*delta

	

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()


func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
