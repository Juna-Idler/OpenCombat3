
class_name SkillData

enum CardColors {NOCOLOR = 0,RED = 1,GREEN = 2,BLUE = 3}

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
	INTEGER,
	EFFECTS,
}

class NamedSkillData:
	var id : int
	var name : String
	var param_type : int
	var parameter
	var text : String
	
	func _init(i:int,n:String,pt:String,p:String,t:String):
		id = i
		name = n
		_set_param_type(pt,p)
		text = t.replace("\\n","\n")
	
	func _set_param_type(pt : String,p : String):
		match pt:
			"Integer":
				param_type = ParamType.INTEGER
				parameter = p
			"Effects":
				param_type = ParamType.EFFECTS
				parameter = p
			_:
				param_type = ParamType.VOID
				parameter = null


class NamedSkill:
	var data : NamedSkillData
	var condition : int

	var parameter
	var text : String
	
	func _init(sd:NamedSkillData,c:String,p:String):
		data = sd
		if sd.param_type == ParamType.VOID:
			parameter = null
			text = sd.text
		else:
			_translate_param(p)
		condition = kanji2condition(c)

	func test_condition(rival_color : int,link_color : int) -> bool :
		if condition & ColorCondition.VS_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == rival_color
		if condition & ColorCondition.LINK_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == link_color
		if condition == ColorCondition.NOCONDITION:
			return true
		return false

	static func kanji2condition(c : String) -> int:
		if c.find("無") >= 0:
			return ColorCondition.NOCONDITION
		if c.find("対赤") >= 0:
			return ColorCondition.VS_RED
		if c.find("対緑") >= 0:
			return ColorCondition.VS_GREEN
		if c.find("対青") >= 0:
			return ColorCondition.VS_BLUE
		if c.find("連赤") >= 0:
			return ColorCondition.LINK_RED
		if c.find("連緑") >= 0:
			return ColorCondition.LINK_GREEN
		if c.find("連青") >= 0:
			return ColorCondition.LINK_BLUE
		return ColorCondition.NOCONDITION
		
	
	func _translate_param(p:String):
		match data.param_type:
			ParamType.INTEGER:
				parameter = int(p)
				var param_string : String = "{" + data.parameter + "}"
				text = data.text.replace(param_string,"{" + p + "}")
			ParamType.EFFECTS:
				parameter = SkillEffects.new(p)
				var param_string : String = "{" + data.parameter + "}"
				text = data.text.replace(param_string,"{" + p + "}")
			_:
				parameter = null
				text = data.text
			


