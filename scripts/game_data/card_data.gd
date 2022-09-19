
class_name CardData

enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}


var id : int
var name : String

var color : int
var level : int
var power : int
var hit : int
var skills : Array# of BaseSkill
var text : String
#var abilities : Array

func _init(i : int,n : String,
		c : int,l : int,p : int,h : int,
		s : Array,t : String):
	id = i
	name = n
	color = c
	level = l
	power = p
	hit = h
	skills = s
	text = t


static func copy(dest : CardData, src : CardData):
	dest.id = src.id
	dest.name = src.name
	dest.color = src.color
	dest.level = src.level
	dest.power = src.power
	dest.hit = src.hit
	dest.skills = src.skills
	dest.text = src.text





