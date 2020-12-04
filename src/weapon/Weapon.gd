extends Spatial

var damage = 10
enum {SEMI, AUTO, BURST}

onready var anim = $AnimationPlayer
onready var bullet = $BulletRay
var mode

func _ready():
	mode = BURST
	

func _process(_delta):
	match mode:
		SEMI:
			if Input.is_action_just_pressed("fire"):
				fire(1)
		AUTO:
			if Input.is_action_pressed("fire"):
				fire(1)
		
		BURST:
			if Input.is_action_pressed("fire"):
				fire(10)
		
func fire(shot_num):
	var i = 1
	while i <= shot_num:
		if anim.is_playing():
			return
		else:
			anim.play("shot")
			$AudioStreamPlayer3D.play()
			if bullet.is_colliding():
				var target = bullet.get_collider()
				if target.has_method("hit"):
					target.hit(damage)
			yield(anim,"animation_finished")
			i += 1
	
func aim(pos):
	bullet.cast_to = to_local(pos)
