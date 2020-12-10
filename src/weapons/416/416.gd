extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 10
	fire_rate = 1
	permited_modes = [AUTO, BURST]
	default_mode = AUTO
	clip_size = 320000
	recoil_force = Vector3(0.5, 0.5, 0.1)
	spread = 0.1
	load_data()
