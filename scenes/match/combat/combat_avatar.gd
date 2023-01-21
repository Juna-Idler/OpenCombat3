# warning-ignore-all:return_value_discarded

tool

extends Node2D

class_name CombatAvatar

onready var avatar := $Image

onready var skills := $SkillList.get_children()
# [$SkillList/Skill1, $SkillList/Skill2,$SkillList/Skill3,$SkillList/Skill4]

onready var states : Array


export(bool) onready var opponent_layout : bool setget set_opponent_layout

var current_effect_line : CombatEffectLine

var power : int
var hit : int
var block : int
var damage : int 

enum AttackType {SHOOTING,CLOSE,IMMOBILE}

var attack_type : int

var magazine := CombatAvatarMagazine.new(10)


func set_opponent_layout(value):
	opponent_layout = value
	if opponent_layout:
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
		for i in $StateList.get_children():
			var item := i as CombatStateLine
			item.rotation_degrees = 180
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
		for i in $StateList.get_children():
			var item := i as CombatStateLine
			item.rotation_degrees = 0
			item.target_position = Vector2(880,360)
		

func initialize(cd : CatalogData.CardData,vs_color : int,link_color : int,active_states : Array):
	$Image/Image/Picture.texture = load("res://card_images/"+ cd.image +".png")
	$Image/Image/Frame.self_modulate = CatalogData.RGB[cd.color]
	
	attack_type = AttackType.SHOOTING if cd.hit > 0 else AttackType.IMMOBILE
	damage = 0;
	$Image/BlockDamage/Label.text = ""
	$Image/Damage/Label.text = ""
	
	for i in cd.skills.size():
		var s := cd.skills[i] as CatalogData.CardSkill
		if s.data.id == 2:
			attack_type = AttackType.CLOSE
		var csl := skills[i] as CombatSkillLine
		csl.set_skill(cd.skills[i],vs_color,link_color)
		csl.show()
	for i in range(cd.skills.size(),4):
		var csl := skills[i] as CombatSkillLine
		csl.hide()
	
	if states.size() < active_states.size():
		for i in active_states.size() - states.size():
			var StateLine = preload("res://scenes/match/combat/combat_state_line.tscn")
			var line = StateLine.instance()
			if opponent_layout:
				line.target_position.x = 400
				line.rotation_degrees = 180
			else:
				line.target_position.x = 880
				line.rotation_degrees = 0
			$StateList.add_child(line)
			states.append(line)
	var step := -40.0 if active_states.size() <= 4 else -160.0 / active_states.size()
	for i in active_states.size():
		var s := active_states[i] as MatchEffect.IState
		var csl := states[i] as CombatStateLine
		csl.set_state(s)
		csl.position.y = step * i
		csl.show()
	for i in range(active_states.size(),states.size()):
		var csl := states[i] as CombatStateLine
		csl.hide()


func _ready():
	pass

func set_effect_line(i : int):
	if i >= 0:
		current_effect_line = skills[i]
	else:
		current_effect_line = states[-i-1]

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
	match attack_type:
		AttackType.SHOOTING:
			attack_shoot(count,rival,tween)
		AttackType.CLOSE:
			attack_close(count,rival,tween)

func attack_close(count : int ,rival : CombatAvatar,tween : SceneTreeTween):
	tween.set_parallel(true)
	tween.tween_property($Image,"z_index",1,0)
	tween.tween_property($Image/Block,"modulate:a",0.0,0.1)
	tween.tween_property($Image/Power,"modulate:a",0.0,0.1)
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",-90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",0.0,0.1)
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",0.0,0.1)
	tween.set_parallel(false)
	var move_x = rival.avatar.global_position.x - $Image.global_position.x
	var move_unit = sign(move_x) * 144
	var stay_x = avatar.global_position.x + move_x - move_unit * 1.75

	tween.tween_property($Image,"global_position:x",move_unit * -0.25,0.1).as_relative()\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($Image,"global_position:x",move_x - move_unit,0.3).as_relative()\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(rival,"add_damage",[1])
	tween.tween_property($Image,"global_position:x",stay_x,0.2)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	for i in count - 1:
		tween.tween_property($Image,"global_position:x",move_unit * 0.75,0.1).as_relative()\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_callback(rival,"add_damage",[1])
		tween.tween_property($Image,"global_position:x",stay_x,0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property($Image/Block,"modulate:a",1.0,0.1)
	tween.set_parallel(true)
	tween.tween_property($Image/Power,"modulate:a",1.0,0.1)
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",1.0,0.1)
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",1.0,0.1)
	tween.tween_property($Image,"z_index",0,0)
	tween.set_parallel(false)

func attack_shoot(count : int ,rival : CombatAvatar,tween : SceneTreeTween):
	tween.set_parallel(true)
	tween.tween_property($Image/Block,"modulate:a",0.0,0.1)
	tween.tween_property($Image/Power,"modulate:a",0.0,0.1)
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",-90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",0.0,0.1)
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",0.0,0.1)
	tween.set_parallel(false)
	
	magazine.connect("hit",self,"_on_Bullet_hit",[rival])
	for i in count:
		var target = rival.avatar.global_position - $Image/Hit.global_position
		tween.tween_callback(magazine,"shoot",[self.get_parent(),$Image/Hit.global_position,target,0.5])
		tween.tween_interval(0.2)

	var wait = create_tween()
	wait.tween_interval(1)
	wait.tween_callback(magazine,"disconnect",["hit",self,"_on_Bullet_hit"])
	
	tween.tween_property($Image/Block,"modulate:a",1.0,0.1)
	tween.set_parallel(true)
	tween.tween_property($Image/Power,"modulate:a",1.0,0.1)
	tween.tween_property($Image/Hit/Polygon2D,"rotation_degrees",90.0,0.1).as_relative()\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(rival.get_node("Image/Power"),"modulate:a",1.0,0.1)
	tween.tween_property(rival.get_node("Image/Hit"),"modulate:a",1.0,0.1)
	tween.set_parallel(false)


func _on_Bullet_hit(bullet,rival):
	bullet.vanish()
	rival.add_damage(1)


func add_damage(add_d : int):
	damage += add_d
	if damage <= block:
		play_sound(load("res://sound/剣で打ち合う4.mp3"))
		$Image/BlockDamage/Label.text = str(-damage)
	else:
		play_sound(load("res://sound/小パンチ.mp3"))
		$Image/BlockDamage/Label.text = str(-block) if block > 0 else ""
		$Image/Damage/Label.text = str(damage - block)

		var original_x = avatar.position.x
		var tween = create_tween()
		tween.tween_property($Image,"position:x",32.0,0.1).as_relative()\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property($Image,"position:x",original_x,0.2)\
				.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)	


func play_sound(stream):
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
	
