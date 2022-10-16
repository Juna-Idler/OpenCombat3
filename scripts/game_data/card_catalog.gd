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
	

func get_skill_data(id : int) -> SkillData.NamedSkillData:
	return _skill_catalog[id]

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func get_card_data(id : int) -> CardData:
	return _card_catalog[id]

func new_card_data(id : int) -> CardData:
	var c := _card_catalog[id] as CardData
	return CardData.new(c.id,c.name,c.color,c.level,c.power,c.hit,c.block,c.skills,c.text,c.image)
	
func set_card_data(card : CardData, id : int):
	CardData.copy(card,get_card_data(id))


func get_parameter_string(skill : SkillData.NamedSkill) -> String:
	match skill.data.param_type:
		SkillData.ParamType.INTEGER:
			return str(skill.parameter as int)
		SkillData.ParamType.EFFECTS:
			var result : PoolStringArray = []
			for e_ in (skill.parameter as SkillEffects).effects:
				var e := e_ as SkillEffects.Effect
				var attribute_string = get_effect_attribute_string(e.attribute)
				result.append(attribute_string + "%+d" % e.parameter)
			return result.join(" ")
		SkillData.ParamType.VOID:
			pass
	return ""
	

func get_condition_detailed_string(condition : int) -> String:
	return ["","","","","","赤と対決 ","緑と対決 ","青と対決 ","","赤と連携 ","緑と連携 ","青と連携 "][condition]



func _load_skill_data():
	var namedskill_resource := preload("res://card_data/named_skill_catalog.txt")
	var namedskills = namedskill_resource.text.split("\n")
	for s in namedskills:
		var csv = s.split("\t")
		var id := int(csv[0])
		_skill_catalog[id] = SkillData.NamedSkillData.new(id,csv[1],csv[2],csv[3],csv[4])
	skill_version = int((_skill_catalog[0] as SkillData.NamedSkillData).text)

func _load_card_data():
	var carddata_resource := preload("res://card_data/card_data_catalog.txt")
	var cards = carddata_resource.text.split("\n")
	for c in cards:
		var csv = c.split("\t")
		var skills = []
		var skill_texts = csv[7].split(";")
		if skill_texts.size() == 1 and skill_texts[0] == "":
			skill_texts.resize(0)
		for s in skill_texts:
			var skill_line = s.split(":");
			var condition : String = skill_line[0]
			var skill_id : String = skill_line[1]
			var skill_param : String = skill_line[2]
			var base_data := get_skill_data(int(skill_id))
			skills.append(SkillData.NamedSkill.new(base_data,condition,skill_param))
		var id := int(csv[0])
		_card_catalog[id] = CardData.new(id,csv[1],CardData.kanji2color(csv[2]),
				int(csv[3]),int(csv[4]),int(csv[5]),int(csv[6]),skills,csv[8],csv[9])
	card_version = int((_card_catalog[0] as CardData).name)


