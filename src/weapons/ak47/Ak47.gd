extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	damage = 1
	slug_size = 1
	fire_rate = 7
	max_clip_size = 32
	permited_modes = [AUTO, BURST, SEMI]
	recoil_force = Vector3(0.01, 0.5, 0.05)
	spread = 0.2
	akimbo = true
	slider_mov_dist = 0.1
	mag_reload_rot = 45
	load_data()
