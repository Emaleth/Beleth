extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/sight_materials/ar_sight_mat.tres")
	damage = 1
	fire_rate = 15
	permited_modes = [fire_mode.AUTO, fire_mode.BURST]
	default_mode = fire_mode.AUTO
	clip_size = 320000
	recoil_force = Vector3(0.2, 1, 0.1)
	spread = 0.1
	load_data()
