extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/sight_materials/sr_sight_mat.tres")
	damage = 100
	fire_rate = 1
	permited_modes = [fire_mode.SEMI]
	default_mode = fire_mode.SEMI
	clip_size = 70
	recoil_force = Vector3(0.1, 0.5, 0.1)
	spread = 0.01
	load_data()
