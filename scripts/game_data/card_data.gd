
class_name CardData

enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}


var id : int
var name : String

var color : int
var level : int
var power : int
var hit : int
var block : int
var skills : Array
var text : String
var image : String 


func _init(i : int,n : String,
		c : int,l : int,p : int,h : int,b : int,
		s : Array,t : String,im : String):
	id = i
	name = n
	color = c
	level = l
	power = p
	hit = h
	block = b
	
	skills = s
	text = t
	image = im


static func copy(dest : CardData, src : CardData):
	dest.id = src.id
	dest.name = src.name
	dest.color = src.color
	dest.level = src.level
	dest.power = src.power
	dest.hit = src.hit
	dest.block = src.block
	dest.skills = src.skills
	dest.text = src.text
	dest.image = src.image

static func kanji2color(k : String) -> int:
	match k:
		"赤":
			return CardColors.RED
		"緑":
			return CardColors.GREEN
		"青":
			return CardColors.BLUE
	return CardColors.NOCOLOR
