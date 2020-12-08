extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 17
	fire_rate = 2
	permited_modes = [AUTO]
	default_mode = AUTO
	clip_size = 320000
	recoil_force = Vector2(0, .1)
	v_spread = 0.1
	h_spread = 0.1
	load_data()
