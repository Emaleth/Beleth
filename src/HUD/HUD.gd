extends Control

var ready = false
onready var crosshair = $Crosshair
onready var r_ammo_label = $HBoxContainer/RAmmo
onready var l_ammo_label = $HBoxContainer/LAmmo

func _ready():
	crosshair.position = rect_size / 2
	ready = true

func _on_HUD_resized():
	if ready:
		crosshair.position = rect_size / 2
