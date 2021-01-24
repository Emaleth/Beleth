"""
Singleton for quick creation of 
built-in nodes with default configuration
"""

extends Node

static func request_basic(parent : Node, node : Node) -> Node:
	var new_node : Node = node.new()
	parent.add_child(new_node)
	return new_node
	

static func request_tween(parent : Node) -> Tween:
	var tween : Tween  = Tween.new()
	parent.add_child(tween)
	return tween


static func request_raycast(parent : Node, direction : Vector3, collision_layers : Array) -> RayCast:
	var raycast : RayCast = RayCast.new()
#	raycast.set_collision_mask_bit(Collsio)
	raycast.cast_to = direction
	raycast.enabled = true
	parent.add_child(raycast)
	return raycast
	
	
static func request_timer(parent : Node, callback : String) -> Timer:
	var timer : Timer  = Timer.new()
	timer.one_shot = true
	parent.add_child(timer)
	timer.connect("timeout", parent, callback)
	return timer
