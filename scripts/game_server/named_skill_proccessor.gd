
class_name NamedSkillProccessor


static func Proccess(skill : CardData.NamedSkill,
		myself : ProccessorData.PlayerData,
		rival : ProccessorData.PlayerData,
		timing_before : bool,situation : int):
	var playing_card = myself.get_playing_card()
	match skill.id:
		1:#突進
			if timing_before || situation > 0:
				return
			if situation < 0:
				var stability = int(skill.parameter) + playing_card.variation.rush
				if stability < rival.get_playing_card().get_current_hit():
					return
			var damage = (playing_card.get_current_hit()) + 1 / 2;
			rival.battle_damage += damage
	pass

