class_name CardCatalog

var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}

func _init():
	var namedskill_resource = preload("res://card_data/named_skill_catalog.txt")
#	_skill_catalog[0] = SkillData.NamedSkill.new(0,"","","")
	var namedskills := namedskill_resource.text.split("\n") as PoolStringArray
	var skill_version : String = namedskills[0]
	namedskills.remove(0)
	for s in namedskills:
		var csv = s.split("\t")
		var id := int(csv[0])
		_skill_catalog[id] = SkillData.NamedSkill.new(id,csv[1],csv[2],csv[3])
	
	var carddata_resource := preload("res://card_data/card_data_catalog.txt")
#	_card_catalog[0] = CardData.new(0,"",0,0,0,0,[],"")
	var cards := carddata_resource.text.split("\n") as PoolStringArray
	var card_version : String = namedskills[0]
	cards.remove(0)
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
			var named_param = c_and_t[1].split(":");
			var skill_id := int(named_param[0])
			var skill = SkillData.NamedSkill.new(skill_id,
					get_skill_data(skill_id).name,named_param[2],get_skill_data(skill_id).text)
			skills.append(skill)
		var id := int(csv[0])
		_card_catalog[id] = CardData.new(id,csv[1],
				int(csv[2]),int(csv[3]),int(csv[4]),int(csv[5]),skills,csv[7])

func get_skill_data(id : int) -> SkillData.NamedSkill:
	return _skill_catalog[id]

func get_card_data(id : int) -> CardData:
	return _card_catalog[id]

func new_card_data(id : int) -> CardData:
	var c := _card_catalog[id] as CardData
	return CardData.new(c.id,c.name,c.color,c.level,c.power,c.hit,c.skills,c.text)
	
func set_card_data(card : CardData, id : int):
	CardData.copy(card,get_card_data(id))
	
