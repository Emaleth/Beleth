"""
Node Dispatcher Singletion
call: 'Dispatche.request(arg)' where:
'arg' is either a PackedScene or a String
corresponding to one of entries in the item_list dictionary
"""

extends Node
class_name DispatcherClass

var things : Dictionary = {}
	
	
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
	
