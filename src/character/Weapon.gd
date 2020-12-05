extends Spatial

var damage = 10
enum {SEMI, AUTO, BURST}

var fire_rate = 1
var mode
var actor

onready var anim = $AnimationPlayer
onready var bullet = $BulletRay
onready var bullet_decal = preload("res://src/decals/BulletDecal.tscn")


func _ready():
	actor = get_parent().get_parent()
	anim.playback_speed = fire_rate
	mode = AUTO
	

func _process(_delta):
	match mode:
		SEMI:
			if Input.is_action_just_pressed("fire"):
				fire(1)
		AUTO:
			if Input.is_action_pressed("fire"):
				fire(1)
		
		BURST:
			if Input.is_action_just_pressed("fire"):
				fire(3)
		
func fire(shot_num):
	var i = 1
	while i <= shot_num:
		if anim.is_playing():
			return
		else:
			anim.play("shot")
			$AudioStreamPlayer3D.play()
			actor.camera_shake()
			bullet.force_raycast_update()
			if bullet.is_colliding():
				var target = bullet.get_collider()
				var b = bullet_decal.instance()
				target.add_child(b)
				b.global_transform.origin = bullet.get_collision_point()
				b.look_at(bullet.get_collision_point() + bullet.get_collision_normal(), Vector3.UP)
				if target.has_method("hit"):
					target.hit(damage)
			yield(anim,"animation_finished")
			i += 1
	
func _input(_event):
	if Input.is_action_just_pressed("semi"):
		mode = SEMI
	if Input.is_action_just_pressed("burst"):
		mode = BURST
	if Input.is_action_just_pressed("auto"):
		mode = AUTO
		
