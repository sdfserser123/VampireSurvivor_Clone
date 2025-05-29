extends RayCast2D

@export var damage: float = 2.0
@export var knock_amount: float = 100.0
@export var attack_size: float = 1.0
@export var laser_time: float = 0.5  # thời gian tồn tại của laser

signal remove_from_array

func _ready():
	# Hướng bắn laser mặc định là lên trên, với độ dài 300 pixel
	target_position = Vector2(0, -300)  # Godot 4.x sử dụng target_position thay cast_to
	force_raycast_update()
	start_laser()

func start_laser():
	# Tạo hình cho laser bằng Line2D
	$Line2D.points = [Vector2.ZERO, target_position]
	$Line2D.width = attack_size * 10

	# Bắt đầu đếm thời gian tồn tại
	$Timer.wait_time = laser_time
	$Timer.start()

func _process(delta: float) -> void:
	force_raycast_update()

	if is_colliding():
		var target = get_collider()
		if target and target.has_method("enemy_hit"):
			target.enemy_hit(damage * delta)  # Gây sát thương liên tục mỗi frame

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
