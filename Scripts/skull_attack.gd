extends Area2D

var hp = 1
var speed = 0
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO
var initial_offset = Vector2.ZERO

@onready var master = get_tree().get_first_node_in_group("Boss3")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var skull_explosion = preload("res://Scenes/skull_explose.tscn")

signal remove_from_array(object)
func _ready():
	if player:
		initial_offset = get_random_position()
		position = player.global_position + initial_offset
	angle = global_position.direction_to(player.global_position)
	speed = player.movement_speed * 0.8
	rotation = angle.angle() + deg_to_rad(0)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	position += direction * speed * delta
	rotation = direction.angle()

func get_random_position() -> Vector2:
	var spawn_radius = 150
	var angle = randf_range(0, TAU)
	return Vector2(cos(angle), sin(angle)) * spawn_radius

func explose():
	gpu_particles_2d.emitting = false
	collision_shape_2d.call_deferred("set", "disabled", true)
	var explosionAnim = skull_explosion.instantiate()
	explosionAnim.scale = self.scale*1.5
	explosionAnim.position = global_position
	sprite_2d.visible = false
	get_parent().call_deferred("add_child",explosionAnim)
	explosion_timer.start()

func _on_timer_timeout() -> void:
	explose()

func _on_area_entered(area: Area2D) -> void:
	print("Collided with: ", area.name)
	print("Groups: ", area.get_groups())
	if area.is_in_group("Player"):
		print("Hi")
		explose()


func _on_explosion_timer_timeout() -> void:
	queue_free()
