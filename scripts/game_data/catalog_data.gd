
class_name CatalogData


enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}
const RGB = [Color(0,0,0,0),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]


class CardData:
	var id : int
	var name : String
	var short_name : String
	var ruby_name : String

	var color : int
	var level : int
	var power : int
	var hit : int
	var block : int
	var skills : Array
	var text : String
	var image : String 


	func _init(i : int,n : String,sn : String,rn : String,
			c : int,l : int,p : int,h : int,b : int,
			s : Array,t : String,im : String):
		id = i
		name = n
		short_name = sn
		ruby_name = rn
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
		dest.ruby_name = src.ruby_name
		dest.color = src.color
		dest.level = src.level
		dest.power = src.power
		dest.hit = src.hit
		dest.block = src.block
		dest.skills = src.skills
		dest.text = src.text
		dest.image = src.image



enum ColorCondition {
	NOCONDITION = 0,
	COLOR_BITS = 3,
	VS_FLAG = 4,
	VS_RED = 5,
	VS_GREEN = 6,
	VS_BLUE = 7,
	LINK_FLAG = 8,
	LINK_RED = 9,
	LINK_GREEN = 10,
	LINK_BLUE = 11,
}
enum ParamType {
	VOID = 0,
	INTEGER = 1,
	ATTRIBUTES = 2,
	COLOR = 3,
}

class SkillData:
	var id : int
	var name : String
	var short_name : String
	var ruby_name : String
	var param_type : PoolIntArray # of ParamType
	var parameter : PoolStringArray
	var states : PoolIntArray # of StateData id
	var text : String
	
	func _init(i:int,n:String,sn:String,rn:String,pt:String,p:String,st:String,t:String):
		id = i
		name = n
		short_name = sn
		ruby_name = rn
		param_type = Array(pt.split(","))
		if param_type.size() == 1 and param_type[0] == ParamType.VOID:
			param_type = []
			parameter = []
		else:
			parameter = p.split(",")
		var states_strings := st.split(",")
		if states_strings.size() == 1 and states_strings[0].empty():
			states = []
		else:
			states = Array(states_strings)
		text = t

class SkillParameter:
	var name : String
	var short_name : String
	var data
	
	func _init(n,sn,d):
		name = n
		short_name = sn
		data = d

class CardSkill:
	var data : SkillData
	var condition : int
	var parameter : Array # of SkillParameter
	var text : String
	
	func _init(sd:SkillData,c:int,p : Array):
		data = sd
		condition = c
		parameter = p
		text = data.text
		for i in data.param_type.size():
			var param_string : String = "{" + data.parameter[i] + "}"
			text = text.replace(param_string,"{" + parameter[i].name + "}")
	
	func get_string() -> String:
		if data.param_type.empty():
			return data.name
		return data.name + "(" + get_parameter_string()  + ")"

	func get_short_string() -> String:
		if data.param_type.empty():
			return data.short_name
		return data.short_name + "(" + get_short_parameter_string()  + ")"

	func get_parameter_string() -> String:
		var p_str : PoolStringArray = []
		for p in parameter:
			p_str.append(p.name)
		return p_str.join(",")

	func get_short_parameter_string() -> String:
		var p_str : PoolStringArray = []
		for p in parameter:
			p_str.append(p.short_name)
		return p_str.join(",")


	func test_condition(rival_color : int,link_color : int) -> bool :
		if condition & ColorCondition.VS_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == rival_color
		if condition & ColorCondition.LINK_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == link_color
		if condition == ColorCondition.NOCONDITION:
			return true
		return false



class StateData:
	var id : int
	var name : String
	var short_name : String
	var ruby_name : String
	var parameter : PoolStringArray
	var text : String
	
	func _init(i:int,n:String,sn:String,rn:String,p:String,t:String):
		id = i
		name = n
		short_name = sn
		ruby_name = rn
		if p.empty():
			parameter = []
		else:
			parameter = p.split(",")
		text = t


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
