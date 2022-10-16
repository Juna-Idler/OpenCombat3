
class_name SkillEffects

enum Attribute {
	POWER = 1,
	HIT,
	BLOCK,
	RUSH,
}

var effects : Array
class Effect:
	var attribute : int
	var parameter : int


	func _init(text : String):
		var param_index = 2
		if text.find("勢力") == 0:
			attribute = Attribute.POWER
		if text.find("打点") == 0:
			attribute = Attribute.HIT
		if text.find("防壁") == 0:
			attribute = Attribute.BLOCK
		if text.find("突撃") == 0:
			attribute = Attribute.RUSH
		parameter = int(text.substr(param_index))

func _init(text : String):
	for e in text.split(" "):
		effects.append(Effect.new(e))
