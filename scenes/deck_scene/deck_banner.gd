extends Control


signal card_clicked(dbcard)

const DeckBannerCard = preload("./deck_banner_card.tscn")

var data : DeckData = DeckData.new([],"",[])

var editor_mode := false

func initialize(d : DeckData,e_mode = false):
	data = d
	editor_mode = e_mode


func set_name(name : String):
	data.name = name
	$Name.text = data.name

func set_cards(cards : Array):
	data.cards = cards
	reset_visual()

func set_key_card_indexes(indexes : Array):
	data.key_card_indexes = indexes
	reset_visual()

func remove_card(dbcard):
	var index = $Container.get_children().find(dbcard)
	data.key_card_indexes.remove(index)
	$Container.remove_child(dbcard)
	dbcard.queue_free()
	reset_visual()


func reset_visual():
	$Name.text = data.name
	var cost := 0
	var rgb := [0,0,0,0]
	var level := [0,0,0,0]
	
	for i in data.cards:
		var c := Global.card_catalog.get_card_data(i)
		rgb[c.color] += 1
		level[c.level] += 1
		cost += c.level

	$Information.text = "%s枚/コスト%s\n赤%s枚 緑%s枚 青%s枚\nL1:%s枚 L2:%s枚 L3:%s枚" %\
			[data.cards.size(),cost,rgb[1],rgb[2],rgb[3],level[1],level[2],level[3]]

	for c in $Container.get_children():
		$Container.remove_child(c)
		c.queue_free()
		
	for i in data.key_card_indexes.size():
		var cd := Global.card_catalog.get_card_data(data.cards[data.key_card_indexes[i]])
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
