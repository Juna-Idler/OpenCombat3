
class_name EffectData

enum Attribute {
	POWER = 1,
	HIT,
	BLOCK,
}

class SkillEffectData:
	var id : int
	var pid : String
	var name : String
	var short_name : String
	var text : String

	func _init(i : int,p : String, n : String, sn : String, t : String):
		id = i
		pid = p
		name = n
		short_name = sn
		text = t


class SkillEffect:
	var data : SkillEffectData
	var parameter : int

	func _init(d : SkillEffectData,p : int):
		data = d
		parameter = p


static func create_effect(text : String, catalog : Array) -> SkillEffect:
	for d in catalog:
		var data := d as SkillEffectData
		if text.find(data.pid) == 0:
			return SkillEffect.new(data,int(text.substr(data.pid.length())))
	return null


