
class_name CombatAvatarMagazine

const CABScene = preload("res://scenes/playing_scene/combat/combat_avatar_bullet.tscn")

var magazine : Array = []
var count : int = 1

func _init(magazine_size : int):
	for i in magazine_size:
		magazine.append(CABScene.instance())
		magazine.back().connect("vanished",self,"_on_Bullet_vanished")

func shot(parent : Node,pos : Vector2,angle : float,velocity : float) -> bool:
	if magazine.empty():
		return false
	var bullet = magazine.pop_back()
	bullet.shot(parent,pos,angle,velocity,3,count)
	count += 1
	return true
	
func _on_Bullet_vanished(_self):
	magazine.push_back(_self)


