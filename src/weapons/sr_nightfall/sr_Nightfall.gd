extends "res://src/weapons/_weapon/_Weapon.gd"


func _ready():
	sight_mat = preload("res://resources/materials/sights/triangle_sight.tres")
	bullet_decal = preload("res://src/decals/Nail.tscn")
	sfx = preload("res://assets/sounds/sfx/cannon_01.wav")
	fire_rate = 5 # 50 bullets per second is maximum
	damage = 1
	permited_modes = [fire_mode.BURST, fire_mode.SEMI]
	default_mode = fire_mode.SEMI
	clip_size = 320000
	recoil_force = Vector3(0.05, 0.5, 0.1)
	spread = 0.01
#	slug_size = 8
#	akimbo = true
	slider = $Nightfall/Slider
	slider_mov_dist = 0.120
	load_data()
