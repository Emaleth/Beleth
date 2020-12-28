extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	damage = 1
	fire_rate = 3
	permited_modes = [AUTO, BURST, SEMI]
	max_clip_size = 6
	recoil_force = Vector3(0.5, 5.0, 0.05)
	spread = 2
	slug_size = 10
	bullet_decal = preload("res://src/decals/Hole.tscn")
	fire_sfx = preload("res://assets/sounds/sfx/shoot/rifle.ogg")
#	akimbo = true
	akimbo_offset = Vector3(0.05, 0, 0)
	ads_akimbo_z_rot = 30
	slider_mov_dist = 0.17
	load_data()
