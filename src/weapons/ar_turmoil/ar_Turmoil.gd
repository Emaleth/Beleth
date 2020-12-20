extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/materials/sights/circle_ring_sight.tres")
	sfx = preload("res://assets/sounds/sfx/bang_04.wav")
	fire_rate = 10 # 50 bullets per second is maximum
	damage = 1
	permited_modes = [fire_mode.AUTO, fire_mode.BURST, fire_mode.SEMI]
	default_mode = fire_mode.AUTO
	clip_size = 320000
	recoil_force = Vector3(0.05, 0.5, 0.05)
	spread = 0.05
	slider_mov_dist = 0.24
	load_data()
