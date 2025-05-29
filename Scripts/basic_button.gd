extends TextureButton

@onready var snd_click: AudioStreamPlayer = $snd_click

signal click_end()

func _on_pressed() -> void:
	snd_click.play()

func _on_snd_click_finished() -> void:
	emit_signal("click_end")
