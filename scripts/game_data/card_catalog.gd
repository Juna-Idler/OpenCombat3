class_name CardCatalog

var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}



var card_version : int
var skill_version : int

func _init():
	_load_skill_data()
	_load_card_data()


const _effect_attribute_string_list = ["","力","打","傷","突"]
static func get_effect_attribute_string(attribute:int)->String:
	return _effect_attribute_string_list[attribute]
	

func get_skill_data(name : String) -> SkillData.NamedSkill:
	return _skill_catalog[name]

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func get_card_data(id : int) -> CardData:
	return _card_catalog[id]

func new_card_data(id : int) -> CardData:
	var c := _card_catalog[id] as CardData
	return CardData.new(c.id,c.name,c.color,c.level,c.power,c.hit,c.skills,c.text,c.image)
	
func set_card_data(card : CardData, id : int):
	CardData.copy(card,get_card_data(id))


func _load_skill_data():
	var namedskill_resource := preload("res://card_data/named_skill_catalog.txt")
	var namedskills = namedskill_resource.text.split("\n")
	for s in namedskills:
		var csv = s.split("\t")
		var name : String = csv[1]
		_skill_catalog[name] = SkillData.NamedSkill.new(int(csv[0]),name,
				SkillData.NamedSkill.string2param_type(csv[2]),csv[3],csv[4],"無")
	skill_version = int((_skill_catalog["SkillVersion"] as SkillData.NamedSkill).text)

func _load_card_data():
	var carddata_resource := preload("res://card_data/card_data_catalog.txt")
	var cards = carddata_resource.text.split("\n")
	for c in cards:
		var csv = c.split("\t")
		var skills = []
		var skill_texts = csv[6].split(";")
		if skill_texts.size() == 1 and skill_texts[0] == "":
			skill_texts.resize(0)
		for s in skill_texts:
			var c_and_t = s.split(":",true,1);
			if c_and_t[0] != "named":
				skills.append(SkillData.NormalSkill.new(c_and_t[0],c_and_t[1]))
				continue
			var named = c_and_t[1].split(":");
			var skill_name : String = named[0]
			var base_data := get_skill_data(skill_name)
			skills.append(SkillData.NamedSkill.new(base_data.id,
					base_data.name,base_data.param_type,
					named[1],base_data.text,named[2]))
		var id := int(csv[0])
		_card_catalog[id] = CardData.new(id,csv[1],CardData.kanji2color(csv[2]),
				int(csv[3]),int(csv[4]),int(csv[5]),skills,csv[7],csv[8])
	card_version = int((_card_catalog[0] as CardData).name)


