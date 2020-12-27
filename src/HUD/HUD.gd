extends Control


onready var crosshair = $Crosshair
onready var ammo_label = $HBoxContainer/Ammo

func _ready():
	crosshair.position = rect_size / 2
