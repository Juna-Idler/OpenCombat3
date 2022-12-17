extends Panel

signal return_button_pressed()
signal decide_button_pressed()


var deck_regulation : RegulationData.DeckRegulation
onready var container = $ScrollContainer/HBoxContainer

func initialize(index : int):
	deck_regulation = Global.deck_regulation_list[index]
	_set_label()
	if container:
		container.get_child(index).pressed = true

func _ready():
	for i in Global.deck_regulation_list:
		var r := i as RegulationData.DeckRegulation
		var b := Button.new()
		b.text = r.name
		b.rect_min_size = Vector2(320,64)
		b.toggle_mode = true
		b.connect("pressed",self,"_on_ButtonRegulation_pressed",[r])
		container.add_child(b)

		if deck_regulation and deck_regulation.name == r.name:
			b.pressed = true


func _on_ButtonRegulation_pressed(dr : RegulationData.DeckRegulation):
	deck_regulation = dr
	_set_label()
	for i in Global.deck_regulation_list.size():
		var r := Global.deck_regulation_list[i] as RegulationData.DeckRegulation
		container.get_child(i).pressed = (dr == r)
	


func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_ButtonDecide_pressed():
	emit_signal("decide_button_pressed")

func _set_label():
	$LabelInformation.text =\
		tr("CARDS") + " : %s\n" % deck_regulation.card_count +\
		tr("COST") + " ： %s\n" % deck_regulation.total_cost +\
		tr("LEVEL2") + " ： %s\n" % deck_regulation.level2_limit +\
		tr("LELEL3") + " ： %s\n" % deck_regulation.level3_limit +\
		tr("CARD_ID") + " ： %s\n" % deck_regulation.card_pool_string()

	
