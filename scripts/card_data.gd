
class_name CardData

enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}


var id : int
var name : String

var color : int
var level : int
var power : int
var hit : int
var skills : Array
var text : String
#var abilities : Array

func set_property(pid : int,pname : String,
		pcolor : int,plevel : int,ppower : int,phit : int,
		pskills : Array,ptext : String) -> CardData:
	id = pid
	name = pname
	color = pcolor
	level = plevel
	power = ppower
	hit = phit
	skills = pskills
	text = ptext
	return self
	


static func copy(dest : CardData, src : CardData):
	dest.id = src.id
	dest.name = src.name
	dest.color = src.color
	dest.level = src.level
	dest.power = src.power
	dest.hit = src.hit
	dest.skills = src.skills
	dest.text = src.text



class NamedSkill:
	var id : int
	var name : String
	var parameter : String
	var text : String


