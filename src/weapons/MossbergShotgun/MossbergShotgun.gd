extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	damage = 1
	fire_rate = 2
	permited_modes = [AUTO, BURST, SEMI]
	max_clip_size = 5
	recoil_force = Vector3(0.5, 2.0, 0.1)
	spread = 2
	slug_size = 10
	akimbo = true
	slider_mov_dist = 0.17
	slide_pos = Vector2.DOWN
	load_data()
