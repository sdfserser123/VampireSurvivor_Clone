extends Node

const ICON_PATH = "res://Texture/Retro Inventory/Upgrades/"
const WEAPON_PATH = "res://Sprites/Item/Weapon/"
const UPGRADES = {
	"bullet0": {
		"icon": WEAPON_PATH + "MagicCrystalStaff.png",
		"displayname": "Magical Staff",
		"details": "Shoot Energy Bullet toward closest enemy",
		"level": "Level: 1",
		"prerequisite": ["bullet3"],
		"type": "weapon"
	},
	"bullet1": {
		"icon": WEAPON_PATH + "MagicCrystalStaff.png",
		"displayname":  "Magical Staff",
		"details": "Increase shooting speed",
		"level": "Level: 2",
		"prerequisite": [],
		"type": "weapon"
	},
	"bullet2": {
		"icon": WEAPON_PATH + "MagicCrystalStaff.png",
		"displayname":  "Magical Staff",
		"details": "Shooting 2 Energy Bullet continuosly toward closest enemy",
		"level": "Level: 3",
		"prerequisite": ["bullet1"],
		"type": "weapon"
	},
	"bullet3": {
		"icon": WEAPON_PATH + "MagicCrystalStaff.png",
		"displayname": "Magical Staff",
		"details": "Energy Bullet now pass through another enemy",
		"level": "Level: 4",
		"prerequisite": ["bullet2"],
		"type": "weapon"
	},
	"bullet4": {
		"icon": WEAPON_PATH + "MagicCrystalStaff.png",
		"displayname": "Magical Staff",
		"details": "Shooting 3 Energy Bullet continuosly toward closest enemy",
		"level": "Level: 5",
		"prerequisite": ["bullet3"],
		"type": "weapon"
	},
	
	"bombdrone1": {
		"icon": WEAPON_PATH + "PurpleMagicScroll.png",
		"displayname": "Sigil Detonation",
		"details": "Setup 3 Magic Circles that explode on impact",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"bombdrone2": {
		"icon": WEAPON_PATH + "PurpleMagicScroll.png",
		"displayname": "Sigil Detonation",
		"details": "Increase the Impact of Explosion",
		"level": "Level: 2",
		"prerequisite": ["bombdrone1"],
		"type": "weapon"
	},
	"bombdrone3": {
		"icon": WEAPON_PATH + "PurpleMagicScroll.png",
		"displayname": "Sigil Detonation",
		"details": "Increase the Impact of Explosion",
		"level": "Level: 3",
		"prerequisite": ["bombdrone2"],
		"type": "weapon"
	},
	"bombdrone4": {
		"icon": WEAPON_PATH + "PurpleMagicScroll.png",
		"displayname": "Sigil Detonation",
		"details": "Increase the damage of Explosion",
		"level": "Level: 4",
		"prerequisite": ["bombdrone3"],
		"type": "weapon"
	},
	"bombdrone5": {
		"icon": WEAPON_PATH + "PurpleMagicScroll.png",
		"displayname": "Sigil Detonation",
		"details": "Increase the number of Magic Circle by 2",
		"level": "Level: 5",
		"prerequisite": ["bombdrone4"],
		"type": "weapon"
	},
	"railgun1": {
		"icon": WEAPON_PATH + "YellowMagicScroll.png",
		"displayname": "Arcbolt",
		"details": "Shot 5 bullets continuosly",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"railgun2": {
		"icon": WEAPON_PATH + "YellowMagicScroll.png",
		"displayname": "Arcbolt",
		"details": "Increase damage",
		"level": "Level: 2",
		"prerequisite": ["railgun1"],
		"type": "weapon"
	},
	"railgun3": {
		"icon": WEAPON_PATH + "YellowMagicScroll.png",
		"displayname": "Arcbolt",
		"details": "Increase damage",
		"level": "Level: 3",
		"prerequisite": ["railgun2"],
		"type": "weapon"
	},
	"railgun4": {
		"icon": WEAPON_PATH + "YellowMagicScroll.png",
		"displayname": "Arcbolt",
		"details": "Increase penetration power",
		"level": "Level: 4",
		"prerequisite": ["railgun3"],
		"type": "weapon"
	},
	"railgun5": {
		"icon": WEAPON_PATH + "YellowMagicScroll.png",
		"displayname": "Arcbolt",
		"details": "Now go through all enemies",
		"level": "Level: 5",
		"prerequisite": ["railgun4"],
		"type": "weapon"
	},
	"laserbeam1": {
		"icon": WEAPON_PATH + "BlueMagicScroll.png",
		"displayname": "Mana Ray",
		"details": "Shooting beam on close enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"laserbeam2": {
		"icon": WEAPON_PATH + "BlueMagicScroll.png",
		"displayname": "Mana Ray",
		"details": "Increase Range and Beam",
		"level": "Level: 2",
		"prerequisite": ["laserbeam1"],
		"type": "weapon"
	},
	"laserbeam3": {
		"icon": WEAPON_PATH + "BlueMagicScroll.png",
		"displayname": "Mana Ray",
		"details": "Increase Power Damage and Beam",
		"level": "Level: 3",
		"prerequisite": ["laserbeam2"],
		"type": "weapon"
	},
	"laserbeam4": {
		"icon": WEAPON_PATH + "BlueMagicScroll.png",
		"displayname": "Mana Ray",
		"details": "Increase Range and Beam",
		"level": "Level: 4",
		"prerequisite": ["laserbeam3"],
		"type": "weapon"
	},
	"laserbeam5": {
		"icon": WEAPON_PATH + "BlueMagicScroll.png",
		"displayname": "Mana Ray",
		"details": "Increase Power Damage and Beam",
		"level": "Level: 5",
		"prerequisite": ["laserbeam4"],
		"type": "weapon"
	},
	"electricfield1": {
		"icon": WEAPON_PATH + "GreenMagicScroll.png",
		"displayname": "Thunder Ward",
		"details": "Create an Electricity Field damaging enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"electricfield2": {
		"icon": WEAPON_PATH + "GreenMagicScroll.png",
		"displayname": "Thunder Ward",
		"details": "Increase Radius",
		"level": "Level: 2",
		"prerequisite": ["electricfield1"],
		"type": "weapon"
	},
	"electricfield3": {
		"icon": WEAPON_PATH + "GreenMagicScroll.png",
		"displayname": "Thunder Ward",
		"details": "Increase Power Damage",
		"level": "Level: 3",
		"prerequisite": ["electricfield2"],
		"type": "weapon"
	},
	"electricfield4": {
		"icon": WEAPON_PATH + "GreenMagicScroll.png",
		"displayname": "Thunder Ward",
		"details": "Increase Radius",
		"level": "Level: 4",
		"prerequisite": ["electricfield3"],
		"type": "weapon"
	},
	"electricfield5": {
		"icon": WEAPON_PATH + "GreenMagicScroll.png",
		"displayname": "Thunder Ward",
		"details": "Increase Power Damage",
		"level": "Level: 5",
		"prerequisite": ["electricfield4"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "Inventory_Slot_3.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "Inventory_Slot_3.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "Inventory_Slot_3.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "Inventory_Slot_3.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "Inventory_Slot_8.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "Inventory_Slot_8.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "Inventory_Slot_8.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "Inventory_Slot_8.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"attack1": {
		"icon": ICON_PATH + "Inventory_Slot_2.png",
		"displayname":  "Attack Upgrade",
		"details": "Boosting your Attack by 2",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"attack2": {
		"icon": ICON_PATH + "Inventory_Slot_2.png",
		"displayname":  "Attack Upgrade",
		"details": "Boosting your Attack by 2",
		"level": "Level: 2",
		"prerequisite": ["attack1"],
		"type": "upgrade"
	},
	"attack3": {
		"icon": ICON_PATH + "Inventory_Slot_2.png",
		"displayname":  "Attack Upgrade",
		"details": "Boosting your Attack by 2",
		"level": "Level: 3",
		"prerequisite": ["attack2"],
		"type": "upgrade"
	},
	"attack4": {
		"icon": ICON_PATH + "Inventory_Slot_2.png",
		"displayname":  "Attack Upgrade",
		"details": "Boosting your Attack by 2",
		"level": "Level: 4",
		"prerequisite": ["attack3"],
		"type": "upgrade"
	},
	"health1": {
		"icon": ICON_PATH + "Hearts_Blue_1.png",
		"displayname": "Health",
		"details": "Increase HP",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"health2": {
		"icon": ICON_PATH + "Hearts_Blue_1.png",
		"displayname": "Health",
		"details": "Slightly Increase HP",
		"level": "Level: 2",
		"prerequisite": ["health1"],
		"type": "upgrade"
	},
	"health3": {
		"icon": ICON_PATH + "Hearts_Blue_1.png",
		"displayname": "Health",
		"details": "Modurately Increase HP",
		"level": "Level: 3",
		"prerequisite": ["health2"],
		"type": "upgrade"
	},
	"health4": {
		"icon": ICON_PATH + "Hearts_Blue_1.png",
		"displayname": "Health",
		"details": "Greatly Increase HP",
		"level": "Level: 4",
		"prerequisite": ["health3"],
		"type": "upgrade"
	},
	"magnet1": {
		"icon": ICON_PATH + "Magnet.png",
		"displayname": "Magnet",
		"details": "Increase Pick up Range",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"magnet2": {
		"icon": ICON_PATH + "Magnet.png",
		"displayname": "Magnet",
		"details": "Increase Pick up Range",
		"level": "Level: 2",
		"prerequisite": ["magnet1"],
		"type": "upgrade"
	},
	"heal": {
		"icon": ICON_PATH + "Hearts_Red_1.png",
		"displayname":  "Heal",
		"details": "Heal 10Hp",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}
