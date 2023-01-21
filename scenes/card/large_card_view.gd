extends "../ui/clickable_control.gd"

func _ready():
	pass

func show_layer(cd : CatalogData.CardData):
	$LargeCard.initialize_card(cd)
	$Flavor.text = cd.text
	show()
	
func hide_layer():
	visible = false

func _on_LargeCardView_clicked():
	hide()
