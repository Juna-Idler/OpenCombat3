extends Control


var data : DeckData = DeckData.new([],"",[])

func initialize(d : DeckData):
	data = d
	if data.key_card_indexes.size() < 3:
		data.key_card_indexes.resize(3)

func set_name(name : String):
	data.name = name
	$Name.text = data.name

func set_cards(cards : Array):
	data.cards = cards
	reset_visual()

func set_key_card_indexes(indexes : Array):
	data.key_card_indexes = indexes
	if data.key_card_indexes.size() < 3:
		data.key_card_indexes.resize(3)
	reset_visual()

func set_key_card_index(pos : int,index :int):
	if pos >= data.key_card_indexes.size():
		data.key_card_indexes.resize(pos+1)
	data.key_card_indexes[pos] = index
	reset_visual()


func get_key_card_data(index : int) -> CardData:
	if index < 0 or index >= data.key_card_indexes.size():
		return null
	var i = data.key_card_indexes[index]
	if i == null or i < 0 or i >= data.cards.size():
		return null
	return Global.card_catalog.get_card_data(data.cards[i])


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

	var visual = $HBoxContainer.get_children()
	for i in 3:
		var c := visual[i] as Control
		c.hide()

	for i in data.key_card_indexes.size():
		var c := visual[i] as Control
		var index = data.key_card_indexes[i]
		if index == null or index < 0 or index >= data.cards.size():
			continue
		var cd := Global.card_catalog.get_card_data(data.cards[index])
		c.get_node("Picture").texture = load("res://card_images/"+ cd.image +".png")
		c.get_node("Frame").self_modulate = CardFront.RGB[cd.color]
		c.show()



func _ready():
	reset_visual()
