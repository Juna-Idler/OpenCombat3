tool
extends ColorRect

class_name SkillLine

enum Color3 {NOCOLOR = 0,RED,GREEN,BLUE}
const RGB = [Color(0,0,0,0),Color(0.9,0,0),Color(0,0.7,0),Color(0,0,1)]

export(String,MULTILINE) var bbc_text : String setget set_text
export(Color3) var left_color : int = 0 setget set_left
export(Color3) var right_color : int = 0 setget set_right

onready var label := $RichTextLabel
onready var left := $ColorRectLeft
onready var right := $ColorRectRight

func _ready():
	label.bbcode_text = bbc_text
	label.hint_tooltip = label.text
	left.color = RGB[left_color]
	right.color = RGB[right_color]
	
func set_text(value:String):
	bbc_text = value
	if label == null:
		return
	label.bbcode_text = value
	label.hint_tooltip = label.text

func set_left(value:int):
	left_color = value
	if left == null:
		return
	left.color = RGB[value]
func set_right(value:int):
	right_color = value
	if right == null:
		return
	right.color = RGB[value]
