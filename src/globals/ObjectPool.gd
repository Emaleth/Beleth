extends Node

var items = {
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


func _ready():
	initiate_pools()
	
	
func initiate_pools():
	for i in items:
		for q in items.get(i).max_q:
			items.get(i).pool.append(items.get(i).scene.instance())
		
		
func get_item(obj):
	var first_item = items.get(obj).pool.pop_front()
	if first_item.get_parent():
		first_item.get_parent().remove_child(first_item)
	items.get(obj).pool.append(first_item)
	
	return first_item

