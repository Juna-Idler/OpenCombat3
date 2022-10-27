extends RigidBody2D

class_name CombatAvatarBullet

signal vanished(_self)

var active := false
var shooter : Node
var bullet_id : int

func _ready():
	pass

func shot(parent : Node,pos : Vector2,angle : float,velocity : float,life_time : float,id : int) -> bool:
	if active:
		return false
	active = true
	shooter = parent
	mode = RigidBody2D.MODE_RIGID
	position = pos
	global_rotation = angle
	bullet_id = id
	shooter.add_child(self)
	var impulse = Vector2(cos(angle) * velocity,sin(angle) * velocity)
	apply_central_impulse(impulse)
#	add_central_force(impulse)

	var tween = create_tween()
	tween.tween_interval(life_time)
	tween.tween_callback(self,"vanish",[id])
	return true

func vanish(id : int):
	if active and id == bullet_id:
#		sleeping = true
#		linear_velocity = Vector2(0,0)
		shooter.remove_child(self)
		mode = RigidBody2D.MODE_STATIC
		active = false
		emit_signal("vanished",self)

