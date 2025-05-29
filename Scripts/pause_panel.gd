extends NinePatchRect

var is_paused = false
var player = null
var mouse_over = false
signal disable_panel()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	player = get_tree().get_first_node_in_group("Player")
	if player:
		connect("disable_panel", Callable(player, "resuming"))
		connect("enable_panel", Callable(player, "pausing"))
	
func _input(event):
	if event.is_action_pressed("esc"):
		if is_paused:
			print("trying")
			get_tree().paused = false

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false

func toggle_pausing():
	is_paused = !is_paused
