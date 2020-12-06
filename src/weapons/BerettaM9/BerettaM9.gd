extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"



func _ready():
	damage = 5
	fire_rate = 0.5
	permited_modes = [SEMI]
	default_mode = SEMI
	clip_size = 7
	load_data()
