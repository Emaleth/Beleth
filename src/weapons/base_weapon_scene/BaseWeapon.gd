extends Spatial

enum {SEMI, AUTO, BURST}

var damage
var fire_rate
var mode
var permited_modes
var default_mode
var muzzle_pos
var clip_size

onready var anim = $AnimationPlayer
onready var bullet = $BulletRay
onready var bullet_decal = preload("res://src/decals/BulletDecal.tscn")


func load_data():
	anim.playback_speed = fire_rate
	mode = default_mode
	

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
		if clip_size > 0:
			if anim.is_playing():
				return
			else:
				anim.play("shot")
				clip_size -= 1
				$Muzzle/AudioStreamPlayer3D.play()
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
		else:
			break
			
			
func _input(_event):
	if Input.is_action_just_pressed("semi"):
		if SEMI in permited_modes:
			mode = SEMI
	if Input.is_action_just_pressed("burst"):
		if BURST in permited_modes:
			mode = BURST
	if Input.is_action_just_pressed("auto"):
		if AUTO in permited_modes:
			mode = AUTO
