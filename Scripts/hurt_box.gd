extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var disable_timer: Timer = $DisableTimer

signal hurt(damage)

var hit_once_array = []

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					collision_shape_2d.call_deferred("set","disabled", true)
					disable_timer.start()
				1: #HitOnce
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array", Callable(self,"remove_from_list")):
								area.connect("remove_from_array", Callable(self, "remove_from_list"))
					else:
						return
				2: #DisableHitBox	
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt",damage)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout() -> void:
	collision_shape_2d.call_deferred("set","disabled", false)
