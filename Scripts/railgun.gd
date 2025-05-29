extends Area2D

var level = 1
var hp = 1
var speed = 250
var damage = 2
var knock_amount = 100
var attack_size = 1.0

var direction = Vector2.ZERO 

func _ready():
	if direction == Vector2.ZERO:
		direction = Vector2.UP 
	direction = direction.normalized()
	rotation = direction.angle()
	match level:
		1:
			hp = 1
			attack_size = 1.0
		2:
			hp = 1
			attack_size = 1.0
		3:
			hp = 1
			attack_size = 1.0
			damage = 5
		4:
			hp = 2
			attack_size = 1.0
			damage = 5
		5:
			hp = 999
			attack_size = 1.0
			damage = 5
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()


func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
