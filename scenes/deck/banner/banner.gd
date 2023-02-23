extends Control

class_name DeckBanner


signal card_clicked(dbcard)

const DeckBannerCard = preload("./banner_card.tscn")

var deck_data : DeckData

var editor_mode := false

func initialize(d : DeckData,e_mode = false):
	deck_data = DeckData.new(d.name,d.cards,d.key_cards)
	editor_mode = e_mode
	return self

func _ready():
	$Name.set_message_translation(false)
	$Name.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)
	if deck_data:
		reset_visual()

func get_deck_data() -> DeckData:
	return deck_data

func set_deck_data(d : DeckData):
	deck_data = DeckData.new(d.name,d.cards,d.key_cards)
	reset_visual()

func set_frame_color(color : Color):
	$Panel.self_modulate = color

func set_name(name : String):
	deck_data.name = name
	$Name.text = name

func set_cards(cards : PoolIntArray):
	deck_data.cards = cards
	reset_visual()

func set_key_cards(cards : PoolIntArray):
	deck_data.key_cards = cards
	reset_visual()

func remove_card(dbcard):
	var index = $Container.get_children().find(dbcard)
	var tmp = deck_data.key_cards
	tmp.remove(index)
	deck_data.key_cards = tmp
	$Container.remove_child(dbcard)
	dbcard.queue_free()
	reset_visual()


func reset_visual():
	$Name.text = deck_data.name
	
	var face := deck_data.get_deck_face(Global.card_catalog)

	$Information.bbcode_text = (
		tr("CARDS:%s COST:%s") % [face.cards_count,face.total_cost] + "\n" +
		tr("RED:%s GREEN:%s BLUE:%s") % [face.color[1],face.color[2],face.color[3]] + "\n" +
		tr("L1:%s L2:%s L3:%s") % [face.level[1],face.level[2],face.level[3]])

	for c in $Container.get_children():
		$Container.remove_child(c)
		c.queue_free()
		
	for i in deck_data.key_cards.size():
		var cd := Global.card_catalog._get_card_data(deck_data.key_cards[i])
		var dbcard = DeckBannerCard.instance()
		dbcard.get_node("CardFront").initialize_card(cd)
		if editor_mode:
			dbcard.connect("clicked",self,"_on_Card_clicked",[dbcard])
			dbcard.mouse_filter = Control.MOUSE_FILTER_STOP
		$Container.add_child(dbcard)


func _on_Card_clicked(dbcard):
	emit_signal("card_clicked",dbcard)

