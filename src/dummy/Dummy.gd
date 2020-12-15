extends KinematicBody


var health = 100
var target = Vector3()

onready var anim = $Ybot/AnimationPlayer


func _ready():
	anim.play("Breathing Idle-loop")
	

func _physics_process(_delta):
	if get_parent().get_node("Character"):
		target.x = get_parent().get_node("Character").global_transform.origin.x
		target.y = self.transform.origin.y
		target.z = get_parent().get_node("Character").global_transform.origin.z
		look_at(target, Vector3.UP)
	if health == 0:
		queue_free()

func hit(amount):
	$AudioStreamPlayer3D.play()
	health -= amount
	health = max(health, 0)
	if health == 0:
		queue_free()


