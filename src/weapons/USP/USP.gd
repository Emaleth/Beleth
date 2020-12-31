extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	damage = 1
	fire_rate = 7
	permited_modes = [AUTO, BURST, SEMI]
	max_clip_size = 12
	recoil_force = Vector3(0.01, 0.5, 0.02) # deg, deg, lenght
	spread = 0.2
	slug_size = 1
	akimbo = true
	slider_mov_dist = 0.1
	mag_reload_rot = -45
	slide_pos = Vector2.UP
	load_data()
