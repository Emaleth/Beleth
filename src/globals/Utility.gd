extends Node


### // global references // ###
var console = null
var player = null
var hud = null
var world = null

### // ################# // ###


static func create_new_tween(tween_parent):
	var tween = Tween.new()
	tween_parent.add_child(tween)
	return tween


static func calculate_cosine_wave(wave, time):
	var cosine_wave = cos(time * wave.frequency) * wave.amplitude
#	var sine_wave = sin(PI/2 + time*wave.frequency)* wave.amplitude
	return cosine_wave # sine_wave
