extends TextureRect

@onready var item_texture: TextureRect = $ItemTexture

var upgrade = null

func _ready() -> void:
	if upgrade != null:
		item_texture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
