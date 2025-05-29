extends Node2D


@export var spawns: Array[Spawn_info] = []
	
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var timer: Timer = $Timer

var time = 0
var slime_is_dead = false
var stone_is_dead = false
var final_boss_is_dead = false

signal changetime(time)

func _ready() -> void:
	connect("changetime", Callable(player,"change_time"))

func _on_timer_timeout() -> void:
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.timer_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
					
					if enemy_spawn.is_in_group("Boss1"):
						var boss_instance = enemy_spawn
						boss_instance.connect("slime_defeated", Callable(self, "_on_slime_died"))
						print("Connected to boss signal")
					elif enemy_spawn.is_in_group("Boss2"):
						var boss_instance = enemy_spawn
						boss_instance.connect("stone_defeated", Callable(self, "_on_stone_died"))
						print("Connected to boss signal")
					elif enemy_spawn.is_in_group("Boss3"):
						var boss_instance = enemy_spawn
						boss_instance.connect("final_boss_dying", Callable(self, "_on_final_boss_dying"))
						boss_instance.connect("final_boss_defeated", Callable(self, "_on_final_boss_died"))
						print("Connected to boss signal")
					elif stone_is_dead and enemy_spawn.has_method("_on_stone_defeated"):
						enemy_spawn._on_slime_defeated()
						enemy_spawn._on_stone_defeated()
					elif slime_is_dead and enemy_spawn.has_method("_on_slime_defeated"):
						enemy_spawn._on_slime_defeated()
	emit_signal("changetime", time)
					
func get_random_position():
	var spawn_radius = 160
	var angle = randf_range(0, TAU)

	var x_spawn = player.global_position.x + cos(angle) * spawn_radius
	var y_spawn = player.global_position.y + sin(angle) * spawn_radius
	
	return Vector2(x_spawn, y_spawn)

func _on_slime_died():
	print("slime die?")
	slime_is_dead = true

func _on_stone_died():
	print("stone die?")
	stone_is_dead = true
	
func _on_final_boss_dying():
	print("is dying")
	timer.stop()
	player.disable_attack()
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	for each_enemy in all_enemy:
		each_enemy.stop_moving()

func _on_final_boss_died():
	print("Final boss die?")
	final_boss_is_dead = true
	
	var all_enemy = get_tree().get_nodes_in_group("Enemy")
	for each_enemy in all_enemy:
		each_enemy.death()
