extends TextureRect

@onready var item_level: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect

var upgrade = null

func _ready() -> void:
	if upgrade != null:
		texture_rect.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
		var level = UpgradeDb.UPGRADES[upgrade]["level"]
		var last_char = level[-1]
		item_level.text = str("Lv.") + str(last_char)
