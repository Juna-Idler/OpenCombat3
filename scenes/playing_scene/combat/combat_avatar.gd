tool

extends Node2D

class_name CombatAvatar

onready var avatar := $Image

onready var skills := $SkillList.get_children()
# [$SkillList/Skill1, $SkillList/Skill2,$SkillList/Skill3,$SkillList/Skill4]

export(bool) onready var opponent_layout : bool = false setget set_opponent_layout

var power : int
var hit : int
var block : int
var damage : int 


func set_opponent_layout(value):
	opponent_layout = value
	if value:
		rotation_degrees = 180
		$Image/Power/Label.rect_rotation = 180
		$Image/Hit/Label.rect_rotation = 180
		$Image/Block/Label.rect_rotation = 180
		$Image/Damage/Label.rect_rotation = 180
		$Image/BlockDamage/Label.rect_rotation = 180
		for i in $SkillList.get_children():
			var item := i as CombatSkillLine
			item.rotation_degrees = 180
			item.opponent_layout = true
			item.target_position = Vector2(400,360)
	else:
		rotation_degrees = 0
		$Image/Power/Label.rect_rotation = 0
		$Image/Hit/Label.rect_rotation = 0
		$Image/Block/Label.rect_rotation = 0
		$Image/Damage/Label.rect_rotation = 0
		$Image/BlockDamage/Label.rect_rotation = 0
		for i in $SkillList.get_children():
			var item := i as CombatSkillLine
			item.rotation_degrees = 0
			item.opponent_layout = false
			item.target_position = Vector2(880,360)
		

func initialize(cd : CardData):
	$Image/Image/Picture.texture = load("res://card_images/"+ cd.image +".png")
	$Image/Image/Frame.self_modulate = CardData.RGB[cd.color]
	
	damage = 0;
	$Image/BlockDamage/Label.text = ""
	$Image/Damage/Label.text = ""


func _ready():
	pass

func set_power(p : int):
	power = p
	$Image/Power/Label.text = str(p)
func set_hit(h : int):
	hit = h
	$Image/Hit/Label.text = str(h)
func set_block(b : int):
	block = b
	$Image/Block/Label.text = str(b)


func attack(count : int ,rival : CombatAvatar,tween : SceneTreeTween):
	tween.tween_property($Image,"z_index",1,0)
	tween.tween_property($Image/Block,"modulate:a",0.0,0.1)
	tween.parallel()
	tween.tween_property($Image/Power,"modulate:a",0.0,0.1)
	tween.parallel()
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",-90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",0.0,0.1)
	tween.parallel()
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",0.0,0.1)
			
	var original_x = avatar.position.x
	for i in count:
		tween.tween_property($Image,"position:x",0.0,0.1)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_callback(rival,"add_damage",[1])
		tween.tween_property($Image,"position:x",original_x,0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)	
				
	tween.tween_property($Image/Block,"modulate:a",1.0,0.1)
	tween.parallel()
	tween.tween_property($Image/Power,"modulate:a",1.0,0.1)
	tween.parallel()
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",1.0,0.1)
	tween.parallel()
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",1.0,0.1)
	tween.tween_property($Image,"z_index",0,0)

func add_damage(add_d : int):
	damage += add_d
	if damage <= block:
		$Image/BlockDamage/Label.text = str(-damage)
	else:
		$Image/BlockDamage/Label.text = str(-block) if block > 0 else ""
		$Image/Damage/Label.text = str(damage - block)
