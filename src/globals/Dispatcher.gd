"""
Node Dispatcher Singletion
call: 'Dispatche.request(arg)' where:
'arg' is either a PackedScene or a String
corresponding to one of entries in the item_list dictionary
"""

extends Node


var things : Dictionary = {
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


func _ready() -> void:
	initialize_pools()
	
	
func initialize_pools() -> void:
	for item in things:
		for i in things.get(item).max_q:
			things.get(item).pool.append(things.get(item).scene.instance())
		
		
func get_from_pool(thing : String) -> Node:
	var first_thing : Node = things.get(thing).pool.pop_front()
	if first_thing.get_parent():
		first_thing.get_parent().remove_child(first_thing)
	things.get(thing).pool.append(first_thing)
	
	return first_thing


func request(thing) -> Node:
	if thing is PackedScene:
		return instantiate(thing)
	elif thing is String:
		if things.get(thing):
			return get_from_pool(thing)
		else:
			print("Dispatcher: requested item is not a part of the item_list")
			return null
			
	else:
		print("Dispatcher: request() function argument has to be of type NodePath or String")
		return null
		
	
func instantiate(thing : PackedScene) -> Node:
	var new_thing = thing.instance()
	return new_thing
	
