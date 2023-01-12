extends Control

class_name CombatOverlap

onready var p1_avatar := $Player1Avatar
onready var p2_avatar := $Player2Avatar


func _ready():
	pass

func initialize(p1 : MatchPlayer,p2 : MatchPlayer):
	var p1_card := p1.deck_list[p1.playing_card_id] as MatchCard
	var p2_card := p2.deck_list[p2.playing_card_id] as MatchCard
	p1_avatar.set_power(p1_card.get_current_power())
	p1_avatar.set_hit(p1_card.get_current_hit())
	p1_avatar.set_block(p1_card.get_current_block())
	p1_avatar.initialize(p1_card.front.data,p2_card.front.data.color,p1.get_link_color(),p1.states)

	p2_avatar.set_power(p2_card.get_current_power())
	p2_avatar.set_hit(p2_card.get_current_hit())
	p2_avatar.set_block(p2_card.get_current_block())
	p2_avatar.initialize(p2_card.front.data,p1_card.front.data.color,p2.get_link_color(),p2.states)


enum CombatTiming {NoTiming,Before,Engagement,After,Damage,End,}
const _timing_name := ["","Before","Engagement","After","Damage","End"]
func change_timing_label(timing : int):
	$TimingLabel.text = _timing_name[timing]

