extends Area2D

var level = 1
var hp = 999
var speed = 350
var bullet_dmg = 5
var damage = 0
var knock_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var master = get_tree().get_first_node_in_group("Boss2")

signal remove_from_array(object)
func _ready():
	angle = global_position.direction_to(target)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func _physics_process(delta: float) -> void:
	position += angle*speed*delta

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
