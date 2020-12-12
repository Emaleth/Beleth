extends "res://src/weapons/base/BaseWeapon.gd"


func _ready():
	sight_mat = preload("res://resources/sight_materials/shotgun_sight_mat.tres")
	damage = 5
	fire_rate = 2
	permited_modes = [fire_mode.SEMI]
	default_mode = fire_mode.SEMI
	clip_size = 700
	recoil_force = Vector3(0.1, 1, 0.2)
	spread = 2
	slug_size = 21
	load_data()
