extends Area2D

var can_move = false
var level = 1
var hp = 1
var speed = 100
var explosion_dmg = 10
var damage = 0
var attack_size = 1
var enemy_close = []
var explosion_size = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var initial_offset = Vector2.ZERO
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var startup_timer: Timer = $StartupTimer
@onready var explosion = preload("res://Scenes/explosion.tscn")
@onready var enemy = get_tree().get_first_node_in_group("Enemy")
@onready var explosion_collision: CollisionShape2D = $ExplosionArea/ExplosionCollision
@onready var explosion_anim: AnimationPlayer = $Sprite2D/explosionAnim
@onready var explosion_area: Area2D = $ExplosionArea
@onready var explosion_timer: Timer = $ExplosionArea/ExplosionTimer

func _ready() -> void:
	explosion_area.connect("body_entered", Callable(self, "_on_explosion_area_body_entered"))
	explosion_collision.scale * explosion_size
	if player:
		initial_offset = get_random_position()
		position = player.global_position + initial_offset
	timer.start()
	startup_timer.start()
	update_movement_direction()  # Ensure initial angle is correct


	match level:
		1:
			hp = 1
			speed = 120
			explosion_dmg = 5
			damage = explosion_dmg * (1 + player.attack_damage * 0.1)
			attack_size = 1.0
			explosion_size = 1.0
		2:
			hp = 1
			speed = 120
			explosion_dmg = 5
			damage = explosion_dmg * (1 + player.attack_damage * 0.1)
			attack_size = 1.0
			explosion_size = 1.5
		3:
			hp = 1
			speed = 120
			explosion_dmg = 5
			damage = explosion_dmg * (1 + player.attack_damage * 0.1)
			attack_size = 1.0
			explosion_size = 2.0
		4:
			hp = 1
			speed = 120
			explosion_dmg = 10
			damage = explosion_dmg * (1 + player.attack_damage * 0.1)
			attack_size = 1.0
			explosion_size = 2.0
		5:
			hp = 1
			speed = 120
			explosion_dmg = 10
			damage = explosion_dmg * (1 + player.attack_damage * 0.1)
			attack_size = 1.0
			explosion_size = 2.0

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	if can_move:
		if target != Vector2.ZERO: # Adjust movement dynamically
			position += angle * speed * delta
	else:
		if player:
			position = player.global_position + initial_offset  # Maintain offset

func update_movement_direction() -> void:
	if target != Vector2.ZERO:
		angle = global_position.direction_to(target)
		rotation = angle.angle() + deg_to_rad(135)  # Adjust rotation
		
func explosioning():
	collision_shape_2d.call_deferred("set", "disabled", true)
	var explosionAnim = explosion.instantiate()
	explosionAnim.scale = self.scale*1.5
	explosionAnim.position = global_position
	self.visible = false
	get_parent().call_deferred("add_child",explosionAnim)
	explosion_timer.start()
	explosion_collision.call_deferred("set", "disabled", false)

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		explosioning()

func _on_startup_timer_timeout() -> void:
	collision_shape_2d.call_deferred("set", "disabled", false)
	can_move = true

func get_random_position() -> Vector2:
	var spawn_radius = 30  # Adjust as needed
	var angle = randf_range(0, TAU)
	return Vector2(cos(angle), sin(angle)) * spawn_radius

func _on_timer_timeout() -> void:
	explosioning()

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):  # đảm bảo enemy có trong group
		body._on_hurt_box_hurt(damage)

func _on_explosion_timer_timeout() -> void:
	queue_free()
