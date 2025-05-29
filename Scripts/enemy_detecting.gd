extends RayCast2D

@onready var player = get_tree().get_first_node_in_group("Player")

@onready var line: Line2D = $Line2D
@onready var casting_particle: GPUParticles2D = $CastingParticle
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var damage_timer: Timer = $DamageTimer
@onready var damage_interval: Timer = $DamageInterval

var target = Vector2.ZERO

var level = 1
var hp = 1
var speed = 100
var bullet_dmg = 1
var damage = 0
var knock_amount = 100
var attack_size = 1.0

var is_hit = true

var angle = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = true
	match level:
		1:
			bullet_dmg = 2
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		2:
			bullet_dmg = 2
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		3:
			bullet_dmg = 3
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		4:
			bullet_dmg = 3
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
		5:
			bullet_dmg = 5
			damage = bullet_dmg * (1 + player.attack_damage * 0.1)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func set_target(enemy_node):
	target = enemy_node

func _process(delta: float) -> void:
	force_raycast_update()
	aim()
	update_laser_line()
	if is_colliding():
		print("is collidingd")
		if is_hit:
			var collider = get_collider()
			if collider.is_in_group("Enemy") or collider.is_in_group("Boss"):
				collider._on_hurt_box_hurt(bullet_dmg)
				is_hit = false
				damage_interval.start()
			

func aim():
	if target != null and target is Node2D:
		# Lấy vị trí toàn cục enemy rồi chuyển về tọa độ local của raycast
		target_position = to_local(target.global_position)
	else:
		# Nếu không có target, hướng mặc định lên trên 1 khoảng
		target_position = Vector2(0, -300)

func update_laser_line():
	line.clear_points()
	line.add_point(Vector2.ZERO)  # gốc
	line.add_point(target_position)
	
	casting_particle.position = target_position # nếu particle nằm ở gốc
	sprite_2d.position = Vector2.ZERO  # nếu particle nằm ở gốc	

func _on_damage_interval_timeout() -> void:
	is_hit = true
	
