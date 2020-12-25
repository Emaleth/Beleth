extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/materials/sights/ring_sight.tres")
#	bullet_decal = preload("res://src/decals/Nail.tscn")
	sfx = preload("res://assets/sounds/sfx/shoot/shotgun.ogg")
	fire_rate = 3 # 50 bullets per second is maximum
	damage = 1
	permited_modes = [fire_mode.SEMI, fire_mode.BURST]
	default_mode = fire_mode.SEMI
	clip_size = 320000
	recoil_force = Vector3(0.2, 5.0, 0.1)
	spread = 2
	slider_mov_dist = 0.2
	slug_size = 20
	load_data()
