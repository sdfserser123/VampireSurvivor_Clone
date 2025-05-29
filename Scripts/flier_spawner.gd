extends Node2D

var slime_die = false
var stone_die = false

@export var flier_scene: PackedScene
@export var flier_num: int = 3
@export var spawn_delay: float = 2.0

@onready var area: Area2D = $Area2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start()
	for i in flier_num:
		var flier = flier_scene.instantiate()
		if slime_die:
			flier._on_slime_defeated()
		if stone_die:
			flier._on_stone_defeated()
		flier.global_position = get_random_position_in_area()
		get_parent().add_child(flier)

func _on_timer_timeout() -> void:
	queue_free()

func get_random_position_in_area() -> Vector2:
	var shape = area.get_node("CollisionShape2D").shape
	var pos = area.global_position
	var offset = Vector2.ZERO
	var radius = shape.radius
	var angle = randf_range(0, TAU)
	var r = sqrt(randf()) * radius
	offset = Vector2(cos(angle), sin(angle)) * r

	return pos + offset
