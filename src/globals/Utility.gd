extends Node


### // global references // ###
var console = null
var player = null
var hud = null
var world = null

### // ################# // ###


static func create_new_tween(parent):
	var tween = Tween.new()
	parent.add_child(tween)
	return tween


static func create_new_raycast(parent):
	var raycast = RayCast.new()
	parent.add_child(raycast)
	return raycast
	

static func calculate_cosine_wave(wave, time):
	var cosine_wave = cos(time * wave.frequency) * wave.amplitude
	return cosine_wave


static func calculate_sine_wave(wave, time):
	var sine_wave = sin(PI/2 + time * wave.frequency) * wave.amplitude
	return sine_wave
