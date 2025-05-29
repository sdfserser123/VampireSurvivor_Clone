extends NinePatchRect

@onready var item_icon: TextureRect = $ItemIcon
@onready var lbl_name: Label = $lbl_name
@onready var lbl_level: Label = $lbl_level
@onready var lbl_description: Label = $lbl_description

var is_showing = false
var mouse_over = false
var player = null
signal disable_panel()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	player = get_tree().get_first_node_in_group("Player")
	if player:
		connect("disable_panel", Callable(player, "disable_treasure"))
	
func _input(event):
	if event.is_action("click"):
		if is_showing:
			print("disable")
			emit_signal("disable_panel")

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false

func toggle_showing():
	is_showing = !is_showing
