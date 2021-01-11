extends Control

onready var js_pos = $joypos
onready var joystick = $joypos/JoyStick
onready var tween = $joypos/Tween



func _ready():
	check_platform()


func check_platform():
	self.hide()

	if OS.get_name() == "Android":
		self.show()
		
	
func _input(event):
	if joystick.is_pressed():
		if tween.is_active():
			tween.stop_all()
		if event is InputEventScreenDrag:
			if event.position.x <= rect_size.x / 2:
				joystick.position += event.relative
				joystick.position = joystick.position.clamped(32.0)

			
	else:
		tween.reset_all()
		tween.interpolate_property(joystick, "position", joystick.position, Vector2.ZERO, 0.1, Tween.TRANS_LINEAR,Tween.EASE_IN)


func _process(_delta):
	get_parent().direction = joystick.position


func _on_VeryTouchy_gui_input(event):
	if event is InputEventScreenDrag:
		get_parent().cam_dir = event.relative

