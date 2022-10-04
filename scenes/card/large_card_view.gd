extends "../ui/clickable_control.gd"

func _ready():
	pass

func show_layer(cd : CardData):
	$LargeCard.initialize_card(cd)
	$Flavor.text = cd.text
	visible = true
	
func hide_layer():
	visible = false

func _on_LargeCardView_clicked():
	hide_layer()
