extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	damage = 1
	fire_rate = 7
	permited_modes = [AUTO, BURST, SEMI]
	clip_size = 666
	recoil_force = Vector3(0.01, 0.5, 0.05)
	spread = 0.2
	slug_size = 1
	bullet_decal = preload("res://src/decals/Hole.tscn")
	sfx = preload("res://assets/sounds/sfx/shoot/rifle.ogg")
#	akimbo = true
	akimbo_offset = Vector3(0.05, 0, 0)
	ads_akimbo_z_rot = 30
	slider_mov_dist = 0.34
	load_data()
