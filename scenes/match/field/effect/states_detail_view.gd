extends Control


const StateLine := preload("res://scenes/match/field/effect/state_line.tscn")

onready var container := $Button/ScrollContainer/VBoxContainer

func _ready():
	container.rect_min_size.x = $Button/ScrollContainer.rect_size.x - 12
	pass

func set_states(states : Array):
	while container.get_child_count() > 0:
		container.remove_child(container.get_child(0))
	for i in states:
		var state := i as MatchEffect.IState
		var state_line := StateLine.instance() as RichTextLabel
		state_line.bbcode_text = state._get_caption() + "\n" + state._get_description()
		container.add_child(state_line)


func _on_Button_pressed():
	hide()

