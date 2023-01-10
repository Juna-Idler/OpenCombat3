# warning-ignore-all:return_value_discarded

class_name MatchSkillPerformer


func _init():
	pass


class Reinforce extends MatchEffect.ISkill:
	var stats : CardData.Stats
	func _init(skill : SkillData.NamedSkill):
		var effect := skill.parameter[0].data as CardData.Stats
		stats = effect.duplicate()

	func _before(_priority : int ,myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		myself.combat_avatar.current_effect_line.succeeded()
		myself.add_attribute(stats.power,stats.hit,stats.block)
		myself.combat_avatar.play_sound(load("res://sound/ステータス上昇魔法2.mp3"))
		var tween = myself.combat_avatar.create_tween()
		tween.tween_interval(1.0)
		yield(tween,"finished")


class Pierce extends MatchEffect.ISkill:
	func _init(_skill : SkillData.NamedSkill):
		pass
	
	func _after(_priority : int,_situation : int,myself : MatchPlayer,rival : MatchPlayer,data) -> void:
		if data > 0:
			myself.combat_avatar.current_effect_line.succeeded()
			var tween = myself.combat_avatar.create_tween()
			myself.combat_avatar.attack_close(data,rival.combat_avatar,tween)
			yield(tween,"finished")
			return
		myself.combat_avatar.current_effect_line.failed()
		yield(myself.combat_avatar.get_tree(),"idle_frame")


class Charge extends MatchEffect.ISkill:
	var stats : CardData.Stats
	var power : int
	var hit : int
	var block : int
	
	func _init(skill : SkillData.NamedSkill):
		var effect := skill.parameter[0].data as CardData.Stats
		stats = effect.duplicate()
	
	func _end(_priority : int,_situation : int,myself : MatchPlayer,_rival : MatchPlayer,data) -> void:
		if data:
			
			
			
			myself.next_effect.power += stats.power
			myself.next_effect.hit += stats.hit
			myself.next_effect.block += stats.block
			
			myself.combat_avatar.current_effect_line.succeeded()
			myself.combat_avatar.play_sound(load("res://sound/オーラ2.mp3"))
			var tween = myself.combat_avatar.create_tween()
			tween.tween_interval(1.0)
			yield(tween,"finished")
			return
		myself.combat_avatar.current_effect_line.failed()
		yield(myself.combat_avatar.get_tree(),"idle_frame")

class Isolate extends MatchEffect.ISkill:
	func _init(_skill : SkillData.NamedSkill):
		pass
	
	func _engaged(_priority : int,_situation : int,myself : MatchPlayer,_rival : MatchPlayer,_data) -> int:
		myself.combat_avatar.current_effect_line.succeeded()
		myself.combat_avatar.add_damage(1)
		yield(myself.combat_avatar.get_tree(),"idle_frame")
		return 0

class Absorb extends MatchEffect.ISkill:
	var stats : CardData.Stats
	func _init(skill : SkillData.NamedSkill):
		var effect := skill.parameter[1].data as CardData.Stats
		stats = effect.duplicate()

	func _before(_priority : int,myself : MatchPlayer,_rival : MatchPlayer,data) -> void:
		if data < 0:
			myself.combat_avatar.current_effect_line.failed()
			yield(myself.combat_avatar.get_tree(),"idle_frame")
			return

		myself.combat_avatar.current_effect_line.succeeded()
		var hand_index := data as int
		var card := myself.deck_list[myself.hand[hand_index]] as MatchCard
		var level = card.front.data.level
		
		myself.discard_card(hand_index,0.5)
		myself.add_attribute(stats.power * level,stats.hit * level,stats.block * level)
		myself.draw_card()
		myself.combat_avatar.play_sound(load("res://sound/ステータス上昇魔法2.mp3"))
		var tween = myself.combat_avatar.create_tween()
		tween.tween_interval(1.0)
		yield(tween,"finished")




