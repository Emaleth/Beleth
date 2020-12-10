extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 17
	fire_rate = 10
	permited_modes = [AUTO]
	default_mode = AUTO
	clip_size = 320000
	recoil_force = Vector3(0.1, 0.1, 0.01)
	spread = 0.5
	load_data()
