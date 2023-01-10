
class_name CardData


class StatsNames:
	var power : String
	var hit : String
	var block : String
	
	var short_power : String
	var short_hit : String
	var short_block : String

	var param_power : String
	var param_hit : String
	var param_block : String

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

	func get_effect_string(names : StatsNames) -> String:
		var texts : PoolStringArray = []
		if power != 0:
			texts.append(names.power + "%+d" % power)
		if hit != 0:
			texts.append(names.hit + "%+d" % hit)
		if block != 0:
			texts.append(names.block + "%+d" % block)
		return texts.join(" ")
	
	func get_short_effect_string(names : StatsNames) -> String:
		var texts : PoolStringArray = []
		if power != 0:
			texts.append(names.short_power + "%+d" % power)
		if hit != 0:
			texts.append(names.short_hit + "%+d" % hit)
		if block != 0:
			texts.append(names.short_block + "%+d" % block)
		return texts.join(" ")

	static func create_from_param_string(param : String,names : StatsNames) -> Stats:
		var r := Stats.new(0,0,0)
		for e in param.split(" "):
			if e.find(names.param_power) == 0:
				r.power = int(e.substr(names.param_power.length()))
			elif e.find(names.param_hit) == 0:
				r.hit = int(e.substr(names.param_hit.length()))
			elif e.find(names.param_block) == 0:
				r.block = int(e.substr(names.param_block.length()))
		return r


enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}

const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

var id : int
var name : String
var short_name : String

var color : int
var level : int
var stats : Stats
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
	stats = Stats.new(p,h,b)
	
	skills = s
	text = t
	image = im


static func copy(dest : CardData, src : CardData):
	dest.id = src.id
	dest.name = src.name
	dest.short_name = src.short_name
	dest.color = src.color
	dest.level = src.level
	dest.stats = src.stats
	dest.skills = src.skills
	dest.text = src.text
	dest.image = src.image
