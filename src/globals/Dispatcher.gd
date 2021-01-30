"""
Node Dispatcher Singletion
call: 'Dispatche.request(arg)' where:
'arg' is either a PackedScene or a String
corresponding to one of entries in the item_list dictionary
"""

extends DispatcherClass


func _ready() -> void:
	# assing things variable
	things = {
		"bullet_hole" : {
			"scene" : preload("res://src/fx/bullet_hit_fx/BulletHitFx.tscn"),
			"max_q" : 1000,
			"pool" : []
		},
		"bullet_trail" : {
			"scene" : preload("res://src/fx/bullet_trail_fx/BulletTrailFx.tscn"),
			"max_q" : 1000,
			"pool" : []
		},
		"gunfire_smoke" : {
			"scene" : preload("res://src/fx/gunfire_smoke_fx/GunfireSmokeFx.tscn"),
			"max_q" : 1000,
			"pool" : []
		},
		"muzzle_flash" : {
			"scene" : preload("res://src/fx/muzzle_flash_fx/MuzzleFlashFx.tscn"),
			"max_q" : 100,
			"pool" : []
		},
		"granade" : {
			"scene" : preload("res://src/projectiles/Projectile.tscn"),
			"max_q" : 100,
			"pool" : []
		}
	}
	#initialize pools
	initialize_pools()
	
