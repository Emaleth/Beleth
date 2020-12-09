extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	sights = $SightsBase
	damage = 10
	fire_rate = 1
	permited_modes = [AUTO, BURST]
	default_mode = AUTO
	clip_size = 320000
	recoil_force = Vector2(-0.1, .5)
	v_spread = 0.1
	h_spread = 0.1
	load_data()
