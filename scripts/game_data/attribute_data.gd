
class_name AttributeData

enum AttributeType {
	POWER = 1,
	HIT,
	BLOCK,
}

class CardAttributeData:
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


class CardAttribute:
	var data : CardAttributeData
	var parameter : int

	func _init(d : CardAttributeData,p : int):
		data = d
		parameter = p


static func create_attribute(text : String, catalog : Array) -> CardAttribute:
	for d in catalog:
		var data := d as CardAttributeData
		if text.find(data.pid) == 0:
			return CardAttribute.new(data,int(text.substr(data.pid.length())))
	return null


