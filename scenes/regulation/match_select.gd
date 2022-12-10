extends Control

signal decided(m_regulation)


onready var list = $ItemList

func _ready():
	for i_ in Global.match_regulation_list:
		var i := i_ as RegulationData.MatchRegulation
		var text = "%s (%s)" % [i.name,i.to_regulation_string()]
		list.add_item(text)


func _on_ButtonBack_pressed():
	hide()


func _on_ButtonDecide_pressed():
	var items = list.get_selected_items()
	if items.empty():
		return
	var index = items[0]
	emit_signal("decided",Global.match_regulation_list[index])
	hide()

func _on_ButtonAdd_pressed():
	var r = RegulationData.MatchRegulation.new($Panel/LineEdit.text,
			int($Panel/SpinBoxHand.value),
			int($Panel/SpinBoxTime.value),
			int($Panel/SpinBoxCA.value),
			int($Panel/SpinBoxRA.value))
	list.add_item("%s (%s)" % [r.name,r.to_regulation_string()])
	Global.match_regulation_list.append(r)


func _on_ButtonDelete_pressed():
	var count = list.get_item_count()
	if count <= 1:
		return
	var items = list.get_selected_items()
	if items.empty():
		return
	var index = items[0]
	if index == 0:
		return
	list.remove_item(index)
	Global.match_regulation_list.pop_at(index)
	
