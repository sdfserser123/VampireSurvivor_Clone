extends TextureButton

var item = null
@onready var player = get_tree().get_first_node_in_group("Player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("pressed", _on_pressed)
	connect("selected_upgrade", Callable(player, "upgrade_character"))

func _on_pressed():
	emit_signal("selected_upgrade", item)
