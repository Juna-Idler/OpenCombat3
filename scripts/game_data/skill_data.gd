
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
	var short_name : String
	var param_type : int
	var parameter : String
	var text : String
	
	func _init(i:int,n:String,sn:String,pt:int,p:String,t:String):
		id = i
		name = n
		short_name = sn
		param_type = pt
		parameter = p
		text = t
	

class NamedSkill:
	var data : NamedSkillData
	var condition : int

	var parameter
	var text : String
	
	func _init(sd:NamedSkillData,c:int,p):
		data = sd
		condition = c
		parameter = p
		
		match data.param_type:
			ParamType.INTEGER:
				var param_string : String = "{" + data.parameter + "}"
				text = data.text.replace(param_string,"{" + parameter + "}")
			ParamType.EFFECTS:
				var param_string : String = "{" + data.parameter + "}"
				var replace_string : PoolStringArray = []
				for e_ in parameter:
					var e := e_ as EffectData.SkillEffect
					replace_string.append(e.data.short_name + "%+d" % e.parameter)
				text = data.text.replace(param_string,"{" + replace_string.join(" ") + "}")
			_:
				text = data.text

	func test_condition(rival_color : int,link_color : int) -> bool :
		if condition & ColorCondition.VS_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == rival_color
		if condition & ColorCondition.LINK_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == link_color
		if condition == ColorCondition.NOCONDITION:
			return true
		return false



