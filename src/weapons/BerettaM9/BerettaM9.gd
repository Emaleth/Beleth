extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"



func _ready():
	damage = 5
	fire_rate = 0.5
	permited_modes = [SEMI]
	default_mode = SEMI
	clip_size = 700
	recoil_force = Vector2(0.1, 1)
	spread = 2
	slug_size = 10
	load_data()
