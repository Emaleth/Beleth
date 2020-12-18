extends Control


onready var input_field = $ConsoleBlock/ConsoleBlockSplit/Cmd/Input
onready var output_field = $ConsoleBlock/ConsoleBlockSplit/Cmd/Output
onready var monitor_field = $ConsoleBlock/ConsoleBlockSplit/Monitor

onready var tween = $Tween
onready var console_block = $ConsoleBlock

var player = null
var target = null

var on_screen = false


func _ready():
	console_block.rect_size.x = rect_size.x
	console_block.rect_size.y = rect_size.y / 3
	console_block.rect_position.y = -console_block.rect_size.y
	

func _process(_delta):
	monitor_player()
	
	
func _input(_event):
	if Input.is_action_just_pressed("console"):
		if on_screen == false:
			show_console()
		elif on_screen == true:
			hide_console()


func _on_Input_text_entered(new_text):
	if new_text == "":
		return
	if output_field.text == "":
		output_field.text += "> " + new_text
	else:
		output_field.text += "\n" + "> " + new_text
	output_field.scroll_vertical = 9999999
	input_field.clear()


func monitor_player():
	if player:
		monitor_field.text = ""
#		monitor_field.text += "Direction: " + str(player.direction) + "\n"
#		monitor_field.text += "Linear Vel: " + str(player.linear_velocity) + "\n"
#		monitor_field.text += "Gravity Vec: " + str(player.gravity_vec) + "\n"
#		monitor_field.text += "Final Vel: " + str(player.velocity) + "\n"
		if player.r_weapon:
			monitor_field.text += "R_hand: " + str(player.r_weapon.name) + "\n"
		if player.l_weapon:
			monitor_field.text += "L_hand: " + str(player.l_weapon.name) + "\n"
		if target:
			if target.health > 0:
				monitor_field.text += "Target: " + str(target.name) + " : " + str(target.health) + "hp" + "\n"
		
func show_console():
	tween.remove_all()
	tween.interpolate_property(console_block, "rect_position:y", console_block.rect_position.y, -console_block.rect_size.y, 0.3 ,Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	on_screen = true
	
	
func hide_console():
	tween.remove_all()
	tween.interpolate_property(console_block, "rect_position:y", console_block.rect_position.y, 0, 0.3 ,Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
	on_screen = false
	
	
	
	
	
	
