extends "res://src/weapons/base_weapon_scene/BaseWeapon.gd"


func _ready():
	damage = 10
	fire_rate = 1
	permited_modes = [AUTO, SEMI]
	default_mode = AUTO
	clip_size = 32
	load_data()
