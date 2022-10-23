extends Control

class_name DeckBanner


signal card_clicked(dbcard)

const DeckBannerCard = preload("./banner_card.tscn")

var deck_name : String
var deck_cards : PoolIntArray
var deck_key_cards : PoolIntArray

var editor_mode := false

func initialize(d : DeckData,e_mode = false):
	deck_name = d.name
	deck_cards = d.cards
	deck_key_cards = d.key_cards
	editor_mode = e_mode
	return self

func get_deck_data() -> DeckData:
	return DeckData.new(deck_name,deck_cards,deck_key_cards)

func set_deck_Data(d : DeckData):
	deck_name = d.name
	deck_cards = d.cards
	deck_key_cards = d.key_cards
	reset_visual()

func set_frame_color(color : Color):
	$Panel.self_modulate = color

func set_name(name : String):
	deck_name = name
	$Name.text = name

func set_cards(cards : PoolIntArray):
	deck_cards = cards
	reset_visual()

func set_key_cards(cards : PoolIntArray):
	deck_key_cards = cards
	reset_visual()

func remove_card(dbcard):
	var index = $Container.get_children().find(dbcard)
	deck_key_cards.remove(index)
	$Container.remove_child(dbcard)
	dbcard.queue_free()
	reset_visual()


func reset_visual():
	$Name.text = deck_name
	var cost := 0
	var rgb := [0,0,0,0]
	var level := [0,0,0,0]
	
	for i in deck_cards:
		var c := Global.card_catalog.get_card_data(i)
		rgb[c.color] += 1
		level[c.level] += 1
		cost += c.level

	$Information.text = "%s枚/コスト%s\n赤%s枚 緑%s枚 青%s枚\nL1:%s枚 L2:%s枚 L3:%s枚" %\
			[deck_cards.size(),cost,rgb[1],rgb[2],rgb[3],level[1],level[2],level[3]]

	for c in $Container.get_children():
		$Container.remove_child(c)
		c.queue_free()
		
	for i in deck_key_cards.size():
		var cd := Global.card_catalog.get_card_data(deck_key_cards[i])
		var dbcard = DeckBannerCard.instance()
		dbcard.get_node("CardFront").initialize_card(cd)
		if editor_mode:
			dbcard.connect("clicked",self,"_on_Card_clicked",[dbcard])
			dbcard.mouse_filter = Control.MOUSE_FILTER_STOP
		$Container.add_child(dbcard)


func _on_Card_clicked(dbcard):
	emit_signal("card_clicked",dbcard)

func _ready():
	reset_visual()
