
class_name SkillData

enum CardColors {NOCOLOR = 0,RED,GREEN,BLUE}

enum ColorCondition {
	NOCONDITION = 0,
	VS_RED,
	VS_GREEN,
	VS_BLUE,
	LINK_RED,
	LINK_GREEN,
	LINK_BLUE,
}
enum Timing {
	BEFORE_JUDGMENT = 1,
	AFTER_JUDGMENT,
	AFTER_SUPERIOR,
	AFTER_INFERIOR,
	AFTER_EQUAL,
	END_COMBAT,
}
enum TargetPlayer {
	MYSELF = 1,
	RIVAL,
	BOTH,
}
enum TargetCard {
	PLAYED_CARD = 1,
	NEXT_CARD,
	HAND_ONE,
	HAND_ALL,
}


class NormalSkill:

	var condition : int
	var timing : int

	var targets : Array
	class Target:
		var target_player : int
		var target_card : int
		var target_color : int
		var effects : NormalSkillEffects# of NormalSkillEffect
			
		func _init(text : String):
			var effects_start = text.find("[")
			var effects_end = text.find("]")
			var target_text = text.substr(0,effects_start)
			var effects_text = text.substr(effects_start + 1,effects_end - effects_start - 1)
			set_target(target_text)
			effects = NormalSkillEffects.new(effects_text)
		
		func set_target(text : String):
			if text.find("自") >= 0:
				target_player = TargetPlayer.MYSELF
			elif text.find("敵") >= 0:
				target_player = TargetPlayer.RIVAL
			elif text.find("両") >= 0:
				target_player = TargetPlayer.BOTH
		
			if text.find("使") >= 0:
				target_card = TargetCard.PLAYED_CARD
				target_color = CardColors.NOCOLOR
			elif text.find("次") >= 0:
				target_card = TargetCard.NEXT_CARD
				target_color = CardColors.NOCOLOR
			else:
				if text.find("赤") >= 0:
					target_color = CardColors.RED
				elif text.find("緑") >= 0:
					target_color = CardColors.GREEN
				elif text.find("青") >= 0:
					target_color = CardColors.BLUE
				else:
					target_color = CardColors.NOCOLOR
				if text.find("一") >= 0:
					target_card = TargetCard.HAND_ONE
				elif text.find("全") >= 0:
					target_card = TargetCard.HAND_ALL


	func _init(condition_text : String,targets_text : String):
		set_condition(condition_text)
		targets = []
		for t in targets_text.split(":"):
			targets.append(Target.new(t))


	func set_condition(text : String):
		if text.find("無") >= 0:
			condition = ColorCondition.NOCONDITION
		elif text.find("対赤") >= 0:
			condition = ColorCondition.VS_RED
		elif text.find("対緑") >= 0:
			condition = ColorCondition.VS_GREEN
		elif text.find("対青") >= 0:
			condition = ColorCondition.VS_BLUE
		elif text.find("連赤") >= 0:
			condition = ColorCondition.LINK_RED
		elif text.find("連緑") >= 0:
			condition = ColorCondition.LINK_GREEN
		elif text.find("連青") >= 0:
			condition = ColorCondition.LINK_BLUE
		else:
			condition = ColorCondition.NOCONDITION
			
		if text.find("前") >= 0:
			timing = Timing.BEFORE_JUDGMENT
		elif text.find("後") >= 0:
			timing = Timing.AFTER_JUDGMENT
		elif text.find("優") >= 0:
			timing = Timing.AFTER_SUPERIOR
		elif text.find("劣") >= 0:
			timing = Timing.AFTER_INFERIOR
		elif text.find("互") >= 0:
			timing = Timing.AFTER_EQUAL
		elif text.find("終") >=0:
			timing = Timing.END_COMBAT
		else:
			timing = 0
		

	func test_condition_before(rival_color : int,link_color : int) -> bool :
		if timing != Timing.BEFORE_JUDGMENT:
			return false
		match condition:
			ColorCondition.NOCONDITION:
				return true
			ColorCondition.VS_RED:
				return rival_color == CardColors.RED
			ColorCondition.VS_GREEN:
				return rival_color == CardColors.GREEN
			ColorCondition.VS_BLUE:
				return rival_color == CardColors.BLUE
			ColorCondition.LINK_RED:
				return link_color == CardColors.RED
			ColorCondition.LINK_GREEN:
				return link_color == CardColors.GREEN
			ColorCondition.LINK_BLUE:
				return link_color == CardColors.BLUE
		return false

	func test_condition_after(rival_color : int,link_color : int,situation : int) -> bool :
		match timing:
			Timing.AFTER_JUDGMENT:
				pass
			Timing.AFTER_SUPERIOR:
				if situation <= 0:
					return false
			Timing.AFTER_INFERIOR:
				if situation >= 0:
					return false
			Timing.AFTER_EQUAL:
				if situation != 0:
					return false
			_:
				return false

		match condition:
			ColorCondition.NOCONDITION:
				return true
			ColorCondition.VS_RED:
				return rival_color == CardColors.RED
			ColorCondition.VS_GREEN:
				return rival_color == CardColors.GREEN
			ColorCondition.VS_BLUE:
				return rival_color == CardColors.BLUE
			ColorCondition.LINK_RED:
				return link_color == CardColors.RED
			ColorCondition.LINK_GREEN:
				return link_color == CardColors.GREEN
			ColorCondition.LINK_BLUE:
				return link_color == CardColors.BLUE
		return false
		
	func test_condition_end(rival_color : int,link_color : int) -> bool :
		if timing != Timing.END_COMBAT:
			return false
		match condition:
			ColorCondition.NOCONDITION:
				return true
			ColorCondition.VS_RED:
				return rival_color == CardColors.RED
			ColorCondition.VS_GREEN:
				return rival_color == CardColors.GREEN
			ColorCondition.VS_BLUE:
				return rival_color == CardColors.BLUE
			ColorCondition.LINK_RED:
				return link_color == CardColors.RED
			ColorCondition.LINK_GREEN:
				return link_color == CardColors.GREEN
			ColorCondition.LINK_BLUE:
				return link_color == CardColors.BLUE
		return false


class NamedSkill:
	enum ParamType {
		VOID = 0,
		INTEGER,
		EFFECTS,
	}
	
	var id : int
	var name : String
	var param_type : int
	var parameter
	var text : String
	var condition : int
	
	func _init(i:int,n:String,pt:int,p:String,t:String,c:String):
		id = i
		name = n
		param_type = pt
		if pt == ParamType.VOID:
			parameter = null
			text = t
		else:
			if p.begins_with("{"):
				parameter = p
				text = t
			else:
				parameter = _translate_param(pt,p)
				text = _translate_text(t,pt,p)
		condition = kanji2condition(c)

	static func kanji2condition(c : String) -> int:
		if c.find("無") >= 0:
			return ColorCondition.NOCONDITION
		if c.find("対赤") >= 0:
			return ColorCondition.VS_RED
		if c.find("対緑") >= 0:
			return ColorCondition.VS_GREEN
		if c.find("対青") >= 0:
			return ColorCondition.VS_GREEN
		if c.find("連赤") >= 0:
			return ColorCondition.LINK_RED
		if c.find("連緑") >= 0:
			return ColorCondition.LINK_GREEN
		if c.find("連青") >= 0:
			return ColorCondition.LINK_BLUE
		return ColorCondition.NOCONDITION
		
	
	static func string2param_type(pt : String) -> int:
		match pt:
			"Integer":
				return ParamType.INTEGER
			"Effects":
				return ParamType.EFFECTS
		return ParamType.VOID
	
	static func _translate_param(pt:int,p:String):
		match pt:
			ParamType.INTEGER:
				return int(p)
			ParamType.EFFECTS:
				return NormalSkillEffects.new(p)
		return null
	
	static func _translate_text(t : String,pt : int,p : String) -> String:
		var param_string = ""
		match pt:
			ParamType.INTEGER:
				param_string = "{Z}"
			ParamType.EFFECTS:
				param_string = "{E}"
		return t.replace(param_string,"{" + p + "}")
		
