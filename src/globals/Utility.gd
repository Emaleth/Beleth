extends Node


### // GLOBAL CONSTANTS // ###


### // GLOBAL REFERENCES // ###
var console : Control = null
var player : KinematicBody = null
var hud : Control = null
var world : Node = null


### // NODE CREATOR // ### 
static func create_new_tween(parent : Node) -> Tween:
	var tween : Tween  = Tween.new()
	parent.add_child(tween)
	return tween


static func create_new_raycast(parent : Node, direction : Vector3, collision_layers : Array) -> RayCast:
	var raycast : RayCast = RayCast.new()
#	raycast.set_collision_mask_bit(Collsio)
	raycast.cast_to = direction
	raycast.enabled = true
	parent.add_child(raycast)
	return raycast
	
	
static func create_new_timer(parent : Node, callback : String) -> Timer:
	var timer : Timer  = Timer.new()
	timer.one_shot = true
	parent.add_child(timer)
	timer.connect("timeout", parent, callback)
	return timer
	
	
### WAVE FUNCTIONS ###
static func calculate_cosine_wave(frequency : float, amplitude : float, time : float) -> float:
	var cosine_wave : float = cos(time * frequency) * amplitude # not safe, can't set type per disctionary key as of Godot 3.2.2.stable
	return cosine_wave


static func calculate_sine_wave(frequency : float, amplitude : float, time : float) -> float:
	var sine_wave : float = sin(PI/2 + time * frequency) * amplitude # not safe, can't set type per disctionary key as of Godot 3.2.2.stable
	return sine_wave


### MISCELLANEOUS ###
static func interpolate_angle(initial, destination, ammount) -> float:
	var new_angle : float
	return new_angle
	
	
