extends Area2D

class_name CombatAvatarBullet

signal vanished(_self)
signal hit(_self)

var parent_node : Node = null
var tween : SceneTreeTween

func _ready():
	pass

func shoot(parent : Node,g_pos : Vector2,r_target : Vector2,duration : float) -> bool:
	if parent_node:
		return false
	parent_node = parent
	parent_node.add_child(self)
	global_position = g_pos
	global_rotation = atan2(r_target.y,r_target.x)
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"global_position",r_target,duration).as_relative()
	tween.tween_callback(self,"vanish")
	return true

func vanish():
	if parent_node:
		parent_node.remove_child(self)
		parent_node = null
		tween.kill()
		emit_signal("vanished",self)


func _on_Bullet_area_entered(area):
	emit_signal("hit",self)
