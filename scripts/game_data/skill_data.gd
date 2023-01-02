
class_name SkillData

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

class NamedSkillData:
	var id : int
	var name : String
	var short_name : String
	var param_type : PoolIntArray
	var parameter : PoolStringArray
	var text : String
	
	func _init(i:int,n:String,sn:String,pt:String,p:String,t:String):
		id = i
		name = n
		short_name = sn
		param_type = Array(pt.split(","))
		if param_type.size() == 1 and param_type[0] == ParamType.VOID:
			param_type = []
			parameter = []
		else:
			parameter = p.split(",")
		text = t

class SkillParameter:
	var name : String
	var short_name : String
	var data
	
	func _init(n,sn,d):
		name = n
		short_name = sn
		data = d

class NamedSkill:
	var data : NamedSkillData
	var condition : int
	var parameter : Array
	var text : String
	
	func _init(sd:NamedSkillData,c:int,p : Array):
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
		var p_str : PoolStringArray = []
		for p in parameter:
			p_str.append(p.name)
		return data.name + "(" + p_str.join(",")  + ")"

	func get_short_string() -> String:
		if data.param_type.empty():
			return data.short_name
		var p_str : PoolStringArray = []
		for p in parameter:
			p_str.append(p.short_name)
		return data.short_name + "(" + p_str.join(",")  + ")"


	func test_condition(rival_color : int,link_color : int) -> bool :
		if condition & ColorCondition.VS_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == rival_color
		if condition & ColorCondition.LINK_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == link_color
		if condition == ColorCondition.NOCONDITION:
			return true
		return false



