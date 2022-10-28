
class_name CombatAvatarMagazine

const CABScene = preload("res://scenes/playing_scene/combat/combat_avatar_bullet.tscn")

signal hit(bullet)

var magazine : Array = []

func _init(magazine_size : int):
	for i in magazine_size:
		var bullet = CABScene.instance()
		magazine.append(bullet)
		bullet.connect("vanished",self,"_on_Bullet_vanished")
		bullet.connect("hit",self,"_on_Bullet_hit")
		

func shoot(parent : Node,g_pos : Vector2,target : Vector2,duration : float) -> bool:
	if magazine.empty():
		return false
	var bullet = magazine.pop_back()
	bullet.shoot(parent,g_pos,target,duration)
	return true
	
func _on_Bullet_vanished(bullet):
	magazine.push_back(bullet)

func _on_Bullet_hit(bullet):
	emit_signal("hit",bullet)

