
class_name CardData


class Stats:
	var power : int
	var hit : int
	var block : int

	func _init(p : int,h : int,b : int):
		power = p
		hit = h
		block = b
		
	func duplicate() -> Stats:
		return Stats.new(power,hit,block)

	func add(other : Stats):
		power += other.power
		hit += other.hit
		block += other.block
	
	func set_stats(p:int,h:int,b:int):
		power = p
		hit = h
		block = b

	func to_array() -> Array:
		return [power,hit,block]

enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}

const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

var id : int
var name : String
var short_name : String

var color : int
var level : int
var power : int
var hit : int
var block : int
var skills : Array
var text : String
var image : String 


func _init(i : int,n : String,sn : String,
		c : int,l : int,p : int,h : int,b : int,
		s : Array,t : String,im : String):
	id = i
	name = n
	short_name = sn
	color = c
	level = l
	power= p
	hit = h
	block = b
	
	skills = s
	text = t
	image = im


static func copy(dest : CardData, src : CardData):
	dest.id = src.id
	dest.name = src.name
	dest.short_name = src.short_name
	dest.color = src.color
	dest.level = src.level
	dest.power = src.power
	dest.hit = src.hit
	dest.block = src.block
	dest.skills = src.skills
	dest.text = src.text
	dest.image = src.image

