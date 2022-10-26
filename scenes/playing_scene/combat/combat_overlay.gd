extends Control

class_name CombatOverlay

onready var my_objects := $MyObjects
onready var rival_objects := $RivalObjects


func _ready():
	pass

func initialize(myself : PlayingPlayer,rival : PlayingPlayer):
	var my_card := myself.deck_list[myself.playing_card_id] as Card
	var rival_card := rival.deck_list[rival.playing_card_id] as Card
	my_objects.power.text = str(my_card.get_current_power())
	my_objects.hit.text = str(my_card.get_current_hit())
	my_objects.block.text = str(my_card.get_current_block())
	my_objects.avatar.initialize(my_card.front.data)

	rival_objects.power.text = str(rival_card.get_current_power())
	rival_objects.hit.text = str(rival_card.get_current_hit())
	rival_objects.block.text = str(rival_card.get_current_block())
	rival_objects.avatar.initialize(rival_card.front.data)

	for i in my_card.front.data.skills.size():
		var csl := my_objects.skills[i] as CombatSkillLine2
		csl.set_skill(my_card.front.data.skills[i],
				rival_card.front.data.color,myself.get_link_color())
		csl.show()
	for i in range(my_card.front.data.skills.size(),4):
		var csl := my_objects.skills[i] as CombatSkillLine2
		csl.hide()
	
	for i in rival_card.front.data.skills.size():
		var csl = rival_objects.skills[i] as CombatSkillLine2
		csl.set_skill(rival_card.front.data.skills[i],
				my_card.front.data.color,rival.get_link_color())
		csl.show()
	for i in range(rival_card.front.data.skills.size(),4):
		var csl := rival_objects.skills[i] as CombatSkillLine2
		csl.hide()


enum CombatTiming {NoTiming,Before,Engagement,After,Damage,End,}
const _timing_name := ["","Before","Engagement","After","Damage","End"]
func change_timing_label(timing : int):
	$TimingLabel.text = _timing_name[timing]

