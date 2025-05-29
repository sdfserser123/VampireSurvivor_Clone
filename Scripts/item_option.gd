extends NinePatchRect

@onready var item_icon: TextureRect = $ItemIcon
@onready var lbl_name: Label = $lbl_name
@onready var lbl_level: Label = $lbl_level
@onready var lbl_description: Label = $lbl_description

var in_inventory = []
var mouse_over = false
var item = null
var player = null
signal selected_upgrade(upgrade)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	player = get_tree().get_first_node_in_group("Player")
	if player:
		connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == null:
		item = "heal"
	lbl_name.text = UpgradeDb.UPGRADES[item]["displayname"]
	lbl_description.text = UpgradeDb.UPGRADES[item]["details"]
	lbl_level.text = UpgradeDb.UPGRADES[item]["level"]
	item_icon.texture = load(UpgradeDb.UPGRADES[item]["icon"])
	
func _input(event):
	if event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade",item)

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
