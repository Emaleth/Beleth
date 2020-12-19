extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/materials/sights/ring_sight.tres")
	sfx = preload("res://assets/sounds/sfx/bang_03.wav")
	fire_rate = 7 # 50 bullets per second is maximum
	damage = 1
	permited_modes = [fire_mode.SEMI, fire_mode.BURST]
	default_mode = fire_mode.SEMI
	clip_size = 320000
	recoil_force = Vector3(0.2, 1.0, 0.1)
	spread = 1
	slider_mov_dist = 0.1
	slug_size = 20
	load_data()
