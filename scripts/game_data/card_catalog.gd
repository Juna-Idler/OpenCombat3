class_name CardCatalog

var _catalog : Array = []

func _init():
	var f = File.new()
	if f.open("res://card_data/card_list.tres", File.READ) != OK:
		return
	var text = f.get_as_text()
	f.close()
	
	_catalog.append(CardData.new().set_property(0,"",0,0,0,0,[],""))
	var cards = text.split("\n")
	for c in cards:
		var csv = c.split(",")
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
			var skill = CardData.NamedSkill.new()
			skill.id = named_param[0]
			skill.name = named_param[1]
			skill.parameter = named_param[2]
			skill.text = named_param[3]
			skills.append(skill)
		_catalog.append(CardData.new().set_property(
				csv[0],csv[1],csv[2],csv[3],csv[4],csv[5],skills,csv[7]))
		
		

func get_card_data(id : int) -> CardData:
	return _catalog[id]
	
func set_card_data(card : CardData, id : int):
	CardData.copy(card,get_card_data(id))
	
