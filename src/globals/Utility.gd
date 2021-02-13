"""
Utility singleton with helper methods
"""
extends Node
class_name Utility

	
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
	
	
