
class_name EffectData

enum Attribute {
	POWER = 1,
	HIT,
	BLOCK,
}

class SkillEffectData:
	var id : int
	var name : String
	var short_name : String
	var text : String
	var keyword : String

	func _init(i : int, n : String, sn : String, t : String,k : String):
		id = i
		name = n
		short_name = sn
		text = t
		keyword = k


class SkillEffect:
	var data : SkillEffectData
	var parameter : int

	func _init(d : SkillEffectData,p : int):
		data = d
		parameter = p


static func create_effect(text : String, catalog : Array) -> SkillEffect:
	for d in catalog:
		var data := d as SkillEffectData
		if text.find(data.keyword) == 0:
			return SkillEffect.new(data,int(text.substr(data.keyword.length())))
	return null


