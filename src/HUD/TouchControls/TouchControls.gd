extends Control

onready var js_pos = $joypos
onready var joystick = $joypos/JoyStick
onready var tween = $joypos/Tween



func _ready():
	check_platform()
#

func check_platform():
	self.hide()

	if OS.get_name() == "Android":
		self.show()
		
	
func _input(event):
	if joystick.is_pressed():
		if tween.is_active():
			tween.stop_all()
		if event is InputEventScreenDrag:
			joystick.position += event.relative
			joystick.position.x = clamp(joystick.position.x, -32, 32)
			joystick.position.y = clamp(joystick.position.y, -32, 32)
			
	else:
		tween.reset_all()
		tween.interpolate_property(joystick, "position", joystick.position, Vector2.ZERO, 0.1, Tween.TRANS_LINEAR,Tween.EASE_IN)

