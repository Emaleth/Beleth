extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	bullet_decal = preload("res://src/decals/Nail.tscn")
	sight_mat = preload("res://resources/sight_materials/shotgun_sight_mat.tres")
	damage = 1
	fire_rate = 3
	permited_modes = [fire_mode.SEMI, fire_mode.BURST]
	default_mode = fire_mode.SEMI
	clip_size = 700
	recoil_force = Vector3(0.1, 1, 0.2)
	spread = 2
	slug_size = 21
	load_data()
