extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 50
	fire_rate = 0.2
	permited_modes = [SEMI]
	default_mode = SEMI
	clip_size = 70
	recoil_force = Vector2(0.2, 2)
	v_spread = 0.1
	h_spread = 0.1
	load_data()
