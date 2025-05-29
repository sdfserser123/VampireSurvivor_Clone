extends CharacterBody2D

@onready var droneBombProjectile = get_tree().get_first_node_in_group("Attack")
@onready var raycast_spawn: Timer = $RaycastSpawn

var in_inventory = []
var raycasts = []

var is_pausing = false
var can_move = true
var inventory_open = false

var base_movement_speed = 100
var movement_speed = 100.0
var hp = 80
var maxhp = 80
var got_hit = false
var last_movement = Vector2.UP
var attack_damage = 5
var time = 0
var timeresult = ""

var experience = 0
var experience_level = 1
var collected_experience = 0
var pending_level_ups = 0
var previous_experience_level = 1

#Attack
var bullet = preload("res://Scenes/bullet.tscn")
var railgun = preload("res://Scenes/railgun.tscn")
var bombdrone = preload("res://Scenes/bomb_drone.tscn")
var laser_scene = preload("res://Scenes/laser_beam.tscn")

#AttackNodes
@onready var bullet_timer: Timer = $Attack/BulletTimer
@onready var bullet_attack_timer: Timer = $Attack/BulletTimer/BulletAttackTimer
@onready var railgun_timer: Timer = $Attack/RailgunTimer
@onready var railgun_attack_timer: Timer = $Attack/RailgunTimer/RailgunAttackTimer
@onready var bombdrone_timer: Timer = $Attack/BombDroneTimer
@onready var bombdrone_attack_timer: Timer = $Attack/BombDroneTimer/BombDroneAttackTimer
@onready var laser_timer: Timer = $Attack/LaserTimer
@onready var laser_attack_timer: Timer = $Attack/LaserTimer/LaserAttackTimer
@onready var electric_field_timer: Timer = $Attack/ElectricFieldTimer
@onready var electric_field_attack_timer: Timer = $Attack/ElectricFieldTimer/ElectricFieldAttacKTimer
@onready var hit_flash: AnimationPlayer = $Sprite2D/HitFlash

#Upgrades
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var cd = 0
var attack_size = 0
var additional_attack = 0

#bullet
var bullet_ammo = 0
var bullet_baseammo = 1
var bullet_attackspeed = 1
var bullet_level = 0

#railgun
var railgun_ammo = 0
var railgun_baseammo = 3
var railgun_attackspeed = 3
var railgun_level = 0

#bombdrone
var bombdrone_ammo = 0
var bombdrone_baseammo = 3
var bombdrone_attackspeed = 6
var bombdrone_level = 0

#laser
var laser_level = 0
var laser_ammo = 0
var laser_baseammo = 1
var laser_attackspeed = 10
var active_lasers = []

#electricfield
var ef_level = 0
var ef_size = 1
var ef_dmg_speed = 0.25
var can_ef_dmg = false

#EnemyRelated
var enemy_close = []
var enemy_laser_close = []

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player: Node
@onready var collision_timer: Timer = $CollisionTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bomb_drone_spawner: Area2D = $BombDroneSpawner
@onready var grab_collision: CollisionShape2D = $GrabArea/Grab_Collision
@onready var death_animation: AnimationPlayer = $DeathAnimation
@onready var laser_detection : Area2D = $LaserDetection
@onready var enemy_detect_for_laser: Area2D = $EnemyDetectForLaser
@onready var laser_detection_collision: CollisionShape2D = $EnemyDetectForLaser/CollisionShape2D
@onready var electric_field: Area2D = $ElectricField
@onready var electric_field_collision: CollisionShape2D = $ElectricField/CollisionShape2D


#GUI
@onready var exp_bar: TextureProgressBar = $GUILayer/GUI/EXPBar
@onready var label_level: Label = $GUILayer/GUI/LabelLevel
@onready var label_exp: Label = $GUILayer/GUI/LabelEXP
@onready var level_up: NinePatchRect = $GUILayer/GUI/LevelUp
@onready var lbl_leve_up: Label = $GUILayer/GUI/LevelUp/lbl_LeveUp
@onready var upgrade_option: HBoxContainer = $GUILayer/GUI/LevelUp/UpgradeOption
@onready var stats: Label = $GUILayer/ConfigLog/Stat_log/Stats
@onready var stat_log: ColorRect = $GUILayer/ConfigLog/Stat_log
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var lbl_timer: Label = $GUILayer/GUI/LblTimer
@onready var collected_weapon: GridContainer = $GUILayer/GUI/CollectedWeapon
@onready var collected_upgrade: GridContainer = $GUILayer/GUI/CollectedUpgrade
@onready var item_container = preload("res://Scenes/item_container.tscn")
#@onready var itemOption = preload("res://Scenes/option_item.tscn")
@onready var itemOption = preload("res://Scenes/item_option.tscn")
@onready var treasure_collection: NinePatchRect = $GUILayer/GUI/TreasureCollection
@onready var inventory: NinePatchRect = $GUILayer/GUI/Inventory
@onready var weapon_inventory: HBoxContainer = $GUILayer/GUI/Inventory/WeaponInventory
@onready var buff_inventory: HBoxContainer = $GUILayer/GUI/Inventory/BuffInventory
@onready var inventory_item = preload("res://Scenes/inventory_item.tscn")

var treasure_visable = false

@onready var death_panel: NinePatchRect = $GUILayer/GUI/DeathPanel
@onready var lbl_result: Label = $GUILayer/GUI/DeathPanel/lbl_result
@onready var win_panel: NinePatchRect = $GUILayer/GUI/WinPanel
@onready var lbl_timeresult: Label = $GUILayer/GUI/WinPanel/lbl_winning/lbl_timeresult
@onready var lbl_levelresult: Label = $GUILayer/GUI/WinPanel/lbl_winning2/lbl_levelresult
@onready var pause_panel: NinePatchRect = $GUILayer/GUI/PausePanel

@onready var raycast_template = preload("res://Scenes/enemy_detecting.tscn")
#Signal
signal playerdeath	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if inventory_open:
			close_inventory()
		else:
			if not is_pausing:
				pausing()
			else:
				resuming()
	elif event.is_action_pressed("inventory") and not is_pausing:
		if not inventory_open:
			open_inventory()
		else:
			close_inventory()
	if event.is_action_pressed("stats_log"):	
		stat_log.visible = !stat_log.visible

func _process(delta: float) -> void:
	update_lasers_based_on_level(laser_level)
	assign_targets_to_raycasts(raycasts, enemy_laser_close, global_position)
		

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	movement()
	
func _ready() -> void:
	electric_field.visible = false
	electric_field_collision.call_deferred("set","disabled",true)
	set_process_unhandled_input(true)
	treasure_collection.visible = false
	update_stats_log()
	upgrade_character("bullet0")
	add_to_group("Player")
	attack()
	set_expbar(experience, calculate_expcap())
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite_2d.flip_h = false
	elif mov.x < 0:
		sprite_2d.flip_h = true
	
	if mov != Vector2.ZERO:
		last_movement = mov
	
	
	velocity = mov.normalized()*movement_speed
	if got_hit:
		animation_player.play("get_hit")
	elif velocity.x != 0 or velocity.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	move_and_slide()


func attack():
	if bullet_level > 0:
		bullet_timer.wait_time = bullet_attackspeed
		if bullet_timer.is_stopped():
			bullet_timer.start()
	if railgun_level > 0:
		railgun_timer.wait_time = railgun_attackspeed
		if railgun_timer.is_stopped():
			railgun_timer.start()
	if bombdrone_level > 0:
		bombdrone_timer.wait_time = bombdrone_attackspeed
		if bombdrone_timer.is_stopped():
			bombdrone_timer.start()
	if ef_level > 0:
		electric_field.visible = true
		electric_field_timer.wait_time = 0.25
		if electric_field_timer.is_stopped():
			electric_field_timer.start()

func _on_hurt_box_hurt(damage: Variant) -> void:
	var damage_reduction = 100.0 / (100.0 + armor * 20.0)
	var final_damage = clamp(damage * damage_reduction, 1.0, 999.0)
	hp -= round(final_damage)
	update_stats_log()
	update_health_bar()
	if hp <= 0:
		death()
		return
	else:
		collision_shape_2d.call_deferred("set","disabled",true)
		hit_flash.play("hit_flash")
		movement_speed = 0
		modulate.a8 = 100
		got_hit = true
		collision_timer.start()

func death():	
	disable_attack()
	emit_signal("playerdeath")
	get_tree().paused = true
	is_pausing = true
	process_mode = PROCESS_MODE_ALWAYS
	can_move = false
	#death_animation.play("death")
	self.z_index = 7
	animation_player.play("death")

func disable_attack():
	bullet_level = 0
	railgun_level = 0
	bombdrone_level = 0
	laser_level = 0
	
	bullet_timer.stop()
	bullet_attack_timer.stop()
	railgun_timer.stop()
	railgun_attack_timer.stop()
	bombdrone_timer.stop()
	bombdrone_attack_timer.stop()
	laser_timer.stop()
	laser_attack_timer.stop()

func update_health_bar():
	health_bar.max_value = maxhp
	health_bar.value = hp

func update_stats_log():
	stats.text = "movement_speed: " + str(movement_speed) + "\nhp: " + str(hp) + "\nmaxhp: " + str(maxhp) + "\natk: " + str(attack_damage) + "\ndef: " + str(armor) + "\nbullet level:" + str(bullet_level) + "\nrailgun level:" + str(railgun_level) + "\nbomb level:" + str(bombdrone_level)


func _on_collision_timer_timeout() -> void:
	collision_shape_2d.call_deferred("set","disabled",false)
	modulate.a8 = 255

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'get_hit':
		got_hit = false
		movement_speed = base_movement_speed
		update_stats_log()
	if anim_name == 'death':
		var tween = death_panel.create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(death_panel,"position",Vector2(424,145),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.play()

func get_target()->Vector2:
	if enemy_close.size() > 0:
		return get_closest_enemy(global_position, enemy_close).global_position
	else:
		return Vector2.UP

func get_closest_enemy(current_position: Vector2, enemies):
	var closest_enemy = null
	var closest_distance:float = 1e20  # Initialize with a large number
	
	for enemy in enemies:
		var distance = current_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy	
	return closest_enemy

func get_random_position():
	var spawn_radius = get_viewport_rect().size.x / 70
	var angle = randf_range(0, TAU)

	var x_spawn = global_position.x + cos(angle) * spawn_radius
	var y_spawn = global_position.y + sin(angle) * spawn_radius
	
	return Vector2(x_spawn, y_spawn)


func _on_bullet_timer_timeout() -> void:
	bullet_ammo += bullet_baseammo
	bullet_attack_timer.start()


func _on_bullet_attack_timer_timeout() -> void:
	if bullet_ammo > 0:
		var bullet_attack = bullet.instantiate()
		bullet_attack.position = position
		bullet_attack.target = get_target()
		bullet_attack.level = bullet_level
		add_child(bullet_attack)
		bullet_ammo -= 1
		if bullet_ammo > 0:
			bullet_attack_timer.start()
		else:
			bullet_attack_timer.stop()
			
func _on_railgun_timer_timeout() -> void:
	railgun_ammo += railgun_baseammo
	railgun_attack_timer.start()


func _on_railgun_attack_timer_timeout():
	if railgun_ammo > 0:
		var railgun_attack = railgun.instantiate()
		railgun_attack.position = position
		railgun_attack.direction = last_movement.normalized()
		railgun_attack.level = railgun_level
		get_tree().current_scene.add_child(railgun_attack)
		railgun_ammo -= 1
		if railgun_ammo > 0:
			railgun_attack_timer.start()
		else:
			railgun_attack_timer.stop()

func _on_bomb_drone_timer_timeout() -> void:
	bombdrone_ammo += bombdrone_baseammo
	bombdrone_attack_timer.start()

func _on_bomb_drone_attack_timer_timeout() -> void:
	if bombdrone_ammo > 0:
		var bombdrone_attack = bombdrone.instantiate()
		bombdrone_attack.position = position
		# ---- thay dòng direction bằng target
		bombdrone_attack.level = bombdrone_level
		get_tree().current_scene.add_child(bombdrone_attack)
		bombdrone_ammo -= 1
		if bombdrone_ammo > 0:
			bombdrone_attack_timer.start()
		else:
			bombdrone_attack_timer.stop()

func _on_laser_timer_timeout():
	print("Laser timer timeout")
	laser_ammo += laser_baseammo
	laser_attack_timer.start()

func _on_laser_attack_timer_timeout():
	pass

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_enemy_detect_for_laser_body_entered(body: Node2D) -> void:
	if not enemy_laser_close.has(body):
		enemy_laser_close.append(body)

func _on_enemy_detect_for_laser_body_exited(body: Node2D) -> void:
	if enemy_laser_close.has(body):
		enemy_laser_close.erase(body)

func healing():
	hp += (maxhp/5)
	hp = clamp(hp,0,maxhp)
	update_health_bar()
	update_stats_log()

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Loot"):
		var exp = area.collect()
		calculate_experience(exp)
	elif area.is_in_group("Heal"):
		var collect_heal = area.collect()
		healing()
	elif area.is_in_group("Magnet"):
		var collect_magnet = area.collect()
	elif area.is_in_group("Treasure"):
		apply_three_random_upgrades()
		var treasure_collect = area.collect()
	elif area.is_in_group("Cake"):
		winning()
		get_tree().paused = true
		is_pausing = true
		var tween = win_panel.create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(win_panel,"position",Vector2(424,205),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.play()

func calculate_experience(gem_exp):
	var exp_required = calculate_expcap()
	collected_experience += gem_exp
	label_exp.text = str(experience + collected_experience) + "/" + str(exp_required)

	while experience + collected_experience >= exp_required:
		var excess_exp = (experience + collected_experience) - exp_required
		experience_level += 1
		experience = 0
		collected_experience = excess_exp
		exp_required = calculate_expcap()

	experience += collected_experience
	collected_experience = 0

	set_expbar(experience, exp_required)

	if experience_level > previous_experience_level:
		previous_experience_level += 1
		levelUp()

func calculate_expcap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level-19)*3
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value
	
func get_collected_weapon_count():
	var count = 0
	for u in collected_upgrades:
		if UpgradeDb.UPGRADES.has(u) and UpgradeDb.UPGRADES[u]["type"] == "weapon":
			count += 1
	return count

func get_collected_upgrade_count():
	var count = 0
	for u in collected_upgrades:
		if UpgradeDb.UPGRADES.has(u) and UpgradeDb.UPGRADES[u]["type"] == "upgrade":
			count += 1	
	return count

func levelUp():
	upgrade_options.clear()
	label_level.text = str("Level: ", experience_level)
	var tween = level_up.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(level_up,"position",Vector2(226,130),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	level_up.visible = true
	var options = 0
	var optionmax = 3
	while options < optionmax:
		var option_choice = itemOption.instantiate()
		option_choice.item = get_random_item()
		upgrade_option.add_child(option_choice)
		options += 1
	get_tree().paused = true
	is_pausing = true
	
func upgrade_character(upgrade):
	match upgrade:
		"bullet0":
			bullet_level = 1
		"bullet1":
			bullet_level = 2
			bullet_attackspeed -= bullet_attackspeed*0.1
		"bullet2":
			bullet_level = 3
			bullet_baseammo += 1
		"bullet3":
			bullet_level = 4
		"bullet4":
			bullet_level = 5
			bullet_baseammo += 1
		"bombdrone1":
			bombdrone_level = 1
		"bombdrone2":
			bombdrone_level = 2
		"bombdrone3":
			bombdrone_level = 3
		"bombdrone4":
			bombdrone_level = 4
		"bombdrone5":
			bombdrone_level = 5
			bombdrone_baseammo += 2
		"railgun1":
			railgun_level = 1
		"railgun2":
			railgun_level = 2
		"railgun3":
			railgun_level = 3
			railgun_attackspeed = 0.5
		"railgun4":
			railgun_level = 4
			railgun_baseammo = 5
		"railgun5":
			railgun_level = 5
		"laserbeam1":
			laser_level = 1
		"laserbeam2":
			laser_level = 2
			increase_laser_range(100.0)
		"laserbeam3":
			laser_level = 3
		"laserbeam4":
			laser_level = 4
			increase_laser_range(140.0)
		"laserbeam5":
			laser_level = 5
		"electricfield1":
			ef_level = 1
		"electricfield2":
			ef_level = 2
			increase_radius()
		"electricfield3":
			ef_level = 3
		"electricfield4":
			ef_level = 4
			increase_radius()
		"electricfield5":
			ef_level = 5
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
			base_movement_speed += 20.0
		"attack1","attack2","attack3","attack4":
			attack_damage += 1
		"health1","health2","health3","health4":
			var increase = int(maxhp * 0.1)
			var final_hp = int(increase / 10) * 10
			if final_hp == 0:
				final_hp = 10
			maxhp += final_hp
			hp = clamp(hp + final_hp, 0, maxhp)
		"magnet1","magnet2":
			grab_collision.scale = grab_collision.scale*1.5
		"heal":
			healing()
	adjust_gui_collection(upgrade)
	add_in_inventory(upgrade)
	var option_children = upgrade_option.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_up.visible = false
	level_up.position = Vector2(226,700)
	get_tree().paused = false
	is_pausing = false
	print(upgrade)
	update_stats_log()
	calculate_experience(0)
	attack()

func get_upgrade_category(id: String) -> String:
		# Trích phần chữ cái trước số, ví dụ: "bullet2" → "bullet"
	var regex := RegEx.new()
	regex.compile("^([a-zA-Z]+)")
	var result := regex.search(id)
	if result:
		return result.get_string(1) # nhóm đầu tiên (prefix trước số)
	return id

func get_random_item():
	var dblist = []

	# Lấy category hiện tại (đã chọn + đang là option) cho weapon và upgrade
	var weapon_categories = {}
	var upgrade_categories = {}

	for id in collected_upgrades + upgrade_options:
		if UpgradeDb.UPGRADES.has(id):
			var t = UpgradeDb.UPGRADES[id]["type"]
			var category = get_upgrade_category(id)
			if t == "weapon":
				weapon_categories[category] = true
			elif t == "upgrade" or t == "stats":
				upgrade_categories[category] = true

	for i in UpgradeDb.UPGRADES.keys():
		if i in collected_upgrades or i in upgrade_options:
			continue

		if UpgradeDb.UPGRADES[i]["type"] == "item":
			continue

		var prerequisites = UpgradeDb.UPGRADES[i].get("prerequisite", [])
		var can_add = true
		for pre in prerequisites:
			if not pre in collected_upgrades:
				can_add = false
				break
		if not can_add:
			continue

		var t = UpgradeDb.UPGRADES[i]["type"]
		var category = get_upgrade_category(i)

		# Logic giới hạn:
		# - Nếu là weapon, và category đã có thì được chọn (là nâng cấp)
		# - Nếu category chưa có, chỉ được chọn nếu chưa đủ 4 loại weapon
		if t == "weapon":
			if weapon_categories.has(category):
				# category đã có, là nâng cấp => chọn được
				pass
			else:
				if weapon_categories.size() >= 4:
					continue  # quá 4 loại weapon thì ko chọn loại mới
		elif t == "upgrade" or t == "stats":
			if upgrade_categories.has(category):
				# category đã có, là nâng cấp => chọn được
				pass
			else:
				if upgrade_categories.size() >= 4:
					continue  # quá 4 loại upgrade thì ko chọn loại mới

		# Nếu qua hết điều kiện, thêm vào dblist
		dblist.append(i)

	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s) 
	lbl_timer.text = str(get_m, ":", get_s)
	timeresult = lbl_timer.text

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = item_container.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collected_weapon.add_child(new_item)
				"upgrade":
					collected_upgrade.add_child(new_item)
					
func add_in_inventory(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]

	if get_type != "item":
		# Xác định container cần tìm (vũ khí hoặc buff)
		var target_container
		if get_type == "weapon":
			target_container = weapon_inventory
		else:
			target_container = buff_inventory

		# Kiểm tra xem có item nào trong inventory có displayname trùng không
		for child in target_container.get_children():
			if UpgradeDb.UPGRADES[child.upgrade]["displayname"] == get_upgraded_displayname:
				# Nếu đã có, cập nhật upgrade mới và gọi lại _ready() để cập nhật hiển thị
				child.upgrade = upgrade
				child._ready()  # Hoặc viết hàm update_ui() thay vì gọi trực tiếp _ready()
				return  # Không thêm mới nữa

		# Nếu chưa có, tạo item mới
		var new_item = inventory_item.instantiate()
		new_item.upgrade = upgrade
		target_container.add_child(new_item)

func get_available_upgrades() -> Array:
	var available = []

	var weapon_categories = {}
	var upgrade_categories = {}
	for id in collected_upgrades:
		if UpgradeDb.UPGRADES.has(id):
			var t = UpgradeDb.UPGRADES[id]["type"]
			var category = get_upgrade_category(id)
			if t == "weapon":
				weapon_categories[category] = true
			elif t == "upgrade" or t == "stats":
				upgrade_categories[category] = true

	for i in UpgradeDb.UPGRADES.keys():
		if i in collected_upgrades:
			continue
		if UpgradeDb.UPGRADES[i]["type"] == "item":
			continue
		var prerequisites = UpgradeDb.UPGRADES[i].get("prerequisite", [])
		var can_add = true
		for pre in prerequisites:
			if not pre in collected_upgrades:
				can_add = false
				break
		if not can_add:
			continue
		var t = UpgradeDb.UPGRADES[i]["type"]
		var category = get_upgrade_category(i)
		if t == "weapon":
			if !weapon_categories.has(category) and weapon_categories.size() >= 4:
				continue
		elif t == "upgrade" or t == "stats":
			if !upgrade_categories.has(category) and upgrade_categories.size() >= 4:
				continue
		available.append(i)

	return available

func apply_three_random_upgrades():
	var applied_upgrades = []

	var weapon_categories = {}
	var upgrade_categories = {}
	for id in collected_upgrades + upgrade_options:
		if UpgradeDb.UPGRADES.has(id):
			var t = UpgradeDb.UPGRADES[id]["type"]
			var category = get_upgrade_category(id)
			if t == "weapon":
				weapon_categories[category] = true
			elif t == "upgrade" or t == "stats":
				upgrade_categories[category] = true

	var valid_upgrades = []
	var new_weapon_count = 0
	var new_upgrade_count = 0

	for i in UpgradeDb.UPGRADES.keys():
		if i in collected_upgrades or i in upgrade_options:
			continue
		if UpgradeDb.UPGRADES[i]["type"] == "item":
			continue

		var prerequisites = UpgradeDb.UPGRADES[i].get("prerequisite", [])
		var can_add = true
		for pre in prerequisites:
			if not pre in collected_upgrades:
				can_add = false
				break
		if not can_add:
			continue

		var t = UpgradeDb.UPGRADES[i]["type"]
		var category = get_upgrade_category(i)

		if t == "weapon":
			if weapon_categories.has(category):
				pass  # nâng cấp weapon đã có
			else:
				if new_weapon_count >= (4 - weapon_categories.size()):
					continue
				new_weapon_count += 1
		elif t == "upgrade" or t == "stats":
			if upgrade_categories.has(category):
				pass
			else:
				if new_upgrade_count >= (4 - upgrade_categories.size()):
					continue
				new_upgrade_count += 1

		valid_upgrades.append(i)

	valid_upgrades.shuffle()
	var count = min(3, valid_upgrades.size())

	for i in range(count):
		var upgrade = valid_upgrades[i]
		upgrade_character(upgrade)
		applied_upgrades.append(upgrade)

	show_treasure_upgrades(applied_upgrades)

func show_treasure_upgrades(upgrades: Array):
	var container = treasure_collection.get_node("HBoxContainer")
	for child in container.get_children():
		child.queue_free()

	for upgrade in upgrades:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(96,96)
		icon.set_size(Vector2(96, 96))
		icon.EXPAND_FIT_HEIGHT_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
		container.add_child(icon)
	treasure_collection.toggle_showing()
	treasure_collection.visible = true
	treasure_visable = true
	get_tree().paused = true
	is_pausing = true

func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	var tween = death_panel.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(death_panel,"position",Vector2(424,145),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()

func _on_mainmenu_btn_click_end() -> void:
	get_tree().paused = false
	is_pausing = false
	var _level 	= get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func disable_treasure():
	treasure_collection.visible = false
	treasure_collection.toggle_showing()
	treasure_visable = false
	get_tree().paused = false
	is_pausing = false

func winning():
	lbl_levelresult.text = str(experience_level)
	lbl_timeresult.text = timeresult

func pausing():
	print("pausing ")
	pause_panel.toggle_pausing()
	is_pausing = true
	get_tree().paused = true
	var tween = pause_panel.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_panel,"position",Vector2(430,193),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()

func resuming():
	pause_panel.toggle_pausing()
	is_pausing = false
	var tween = pause_panel.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_panel,"position",Vector2(430,783),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	get_tree().paused = false
	print("resuming")
	

func _on_restart_button_pressed() -> void:
	resuming()
	get_tree().reload_current_scene()

func _on_mainmenu_button_pressed() -> void:
	get_tree().paused = false
	is_pausing = false
	var _level 	= get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_resum_buttone_pressed() -> void:
	resuming()

func open_inventory():
	inventory.toggle_inventory()
	inventory_open = true
	get_tree().paused = true
	var tween = inventory.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(inventory,"position",Vector2(0,187),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()

func close_inventory():
	inventory_open = false
	inventory.toggle_inventory()
	var tween = inventory.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(inventory,"position",Vector2(-439,187),0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	get_tree().paused = false


func _on_inventory_button_pressed() -> void:
	if not inventory_open:
		open_inventory()
	else:
		close_inventory()

func update_lasers_based_on_level(level):
	var enemy_count = enemy_laser_close.size()
	var raycast_needed = min(level, enemy_count)

	# Xoá raycast thừa nếu hiện tại nhiều hơn cần thiết
	while raycasts.size() > raycast_needed:
		var old_ray = raycasts.pop_back()
		old_ray.queue_free()

	# Thêm raycast nếu chưa đủ
	while raycasts.size() < raycast_needed:
		var new_ray = raycast_template.instantiate()
		add_child(new_ray)
		raycasts.append(new_ray)

	# Gán target cho từng raycast
	for i in range(raycast_needed):
		var ray = raycasts[i]
		var target = enemy_laser_close[i]
		var direction = (target.global_position - global_position).normalized()
		var distance = global_position.distance_to(target.global_position)
		ray.target_position = direction * distance
		ray.z_index = 0
		ray.force_raycast_update()

func assign_targets_to_raycasts(raycasts: Array, enemies: Array, origin_position: Vector2) -> void:
	var sorted_enemies = enemies.duplicate()
	sorted_enemies.sort_custom(Callable(self, "_compare_enemy_distance").bind(origin_position))
	
	for i in range(raycasts.size()):
		var ray = raycasts[i]
		if i < sorted_enemies.size():
			var target_enemy = sorted_enemies[i]
			ray.set_target(target_enemy)  # <- Gọi setter
		else:
			ray.set_target(null)  # <- Ray mặc định lên trên

func _compare_enemy_distance(origin_position: Vector2, a, b) -> int:
	var dist_a = origin_position.distance_to(a.global_position)
	var dist_b = origin_position.distance_to(b.global_position)
	if dist_a < dist_b:
		return -1
	elif dist_a > dist_b:
		return 1
	else:
		return 0

func increase_laser_range(radius: float):
	laser_detection_collision.shape.radius = radius


func _on_electric_field_timer_timeout() -> void:
	print("zzz")
	electric_field_collision.call_deferred("set","disabled", false)
	electric_field_attack_timer.start()

func _on_electric_field_attac_k_timer_timeout() -> void:
	electric_field_collision.call_deferred("set","disabled", true)
	electric_field_timer.start()
	
func increase_radius():
	electric_field.scale = electric_field.scale*1.4
