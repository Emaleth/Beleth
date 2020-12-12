extends "res://src/weapons/base/BaseWeapon.gd"


func _ready():
	sight_mat = preload("res://resources/sight_materials/smg_sight_mat.tres")
	damage = 1
	fire_rate = 20
	permited_modes = [fire_mode.AUTO]
	default_mode = fire_mode.AUTO
	clip_size = 320000
	recoil_force = Vector3(0.1, 0.1, 0.01)
	spread = 0.5
	load_data()
