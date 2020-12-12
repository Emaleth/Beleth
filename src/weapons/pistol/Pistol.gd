extends "res://src/weapons/base/BaseWeapon.gd"


func _ready():
	sight_mat = preload("res://resources/sight_materials/pistol_sight_mat.tres")
	damage = 5
	fire_rate = 5
	permited_modes = [fire_mode.SEMI, fire_mode.AUTO]
	default_mode = fire_mode.SEMI
	clip_size = 700
	recoil_force = Vector3(0.1, 0.1, 0.01)
	spread = 0.1
	load_data()
