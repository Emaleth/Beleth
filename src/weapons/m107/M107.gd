extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 50
	fire_rate = 0.2
	permited_modes = [SEMI]
	default_mode = SEMI
	clip_size = 70
	recoil_force = Vector3(0.1, 0.1, 0.01)
	spread = 0.5
	load_data()
