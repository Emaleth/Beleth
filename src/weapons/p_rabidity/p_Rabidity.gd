extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/materials/sights/triangle_sight.tres")
#	bullet_decal = preload("res://src/decals/Nail.tscn")
	sfx = preload("res://assets/sounds/sfx/shoot/pistol.ogg")
	fire_rate = 10 # 50 bullets per second is maximum
	damage = 1
	permited_modes = [fire_mode.BURST, fire_mode.SEMI]
	default_mode = fire_mode.SEMI
	clip_size = 320000
	recoil_force = Vector3(0.1, 0.1, 0.02)
	spread = 0.1
	akimbo = true
	slider_mov_dist = 0.033
	load_data()
