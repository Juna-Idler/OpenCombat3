class_name CardCatalog

var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}

var _effect_catalog : Array = []

enum EffectAttribute {
	POWER = 1,
	HIT,
	BLOCK,
}

var version : String

var translation : String

func _init():
	translation = TranslationServer.get_locale()
	
	load_catalog()

func load_catalog():
	_load_effect_data()
	_load_skill_data()
	_load_card_data()
	

func get_effect_data(id:int) -> EffectData.SkillEffectData:
	return _effect_catalog[id]

func get_skill_param(param_type : int,param : String) -> SkillData.SkillParameter:
	match param_type:
		SkillData.ParamType.INTEGER:
			return SkillData.SkillParameter.new(param,param,int(param))
		SkillData.ParamType.EFFECTS:
			var effects = []
			var e_string : PoolStringArray = []
			var e_s_string : PoolStringArray = []
			for e in param.split(" "):
				var effect = EffectData.create_effect(e,_effect_catalog)
				effects.append(effect)
				e_string.append(effect.data.name + "%+d" % effect.parameter)
				e_s_string.append(effect.data.short_name + "%+d" % effect.parameter)
			return SkillData.SkillParameter.new(e_string.join(" "),e_s_string.join(" "),effects)
		SkillData.ParamType.COLOR:
			var ColorName := [tr("NO_COLOR"),tr("RED"),tr("GREEN"),tr("BLUE")]
			return SkillData.SkillParameter.new(ColorName[int(param)],ColorName[int(param)],int(param))
	return null


func get_skill_data(id : int) -> SkillData.NamedSkillData:
	return _skill_catalog[id]

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func get_card_data(id : int) -> CardData:
	return _card_catalog[id]

func new_card_data(id : int) -> CardData:
	var c := _card_catalog[id] as CardData
	return CardData.new(c.id,c.name,c.short_name,c.color,c.level,c.power,c.hit,c.block,c.skills,c.text,c.image)
	
func set_card_data(card : CardData, id : int):
	CardData.copy(card,get_card_data(id))


func get_deck_face(deck : DeckData) -> DeckData.DeckFace:
	var cost := 0
	var rgb := [0,0,0,0]
	var level := [0,0,0,0]
	for i in deck.cards:
		var c := Global.card_catalog.get_card_data(i) as CardData
		rgb[c.color] += 1
		level[c.level] += 1
		cost += c.level
	return DeckData.DeckFace.new(deck.name,deck.key_cards,deck.cards.size(),cost,level,rgb)


func _load_effect_data():
	var effect_resource = preload("res://card_data/skill_effect_catalog.txt")
	var effects = effect_resource.text.split("\n")
	_effect_catalog.resize(effects.size())
	_effect_catalog[0] = EffectData.SkillEffectData.new(0,"","","","")
	for s in effects:
		var csv = s.split("\t")
		var id := int(csv[0])
		_effect_catalog[id] = EffectData.SkillEffectData.new(id,csv[1],csv[2],csv[3],csv[4])

	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/skill_effect_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/skill_effect_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _effect_catalog[id] as EffectData.SkillEffectData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.text = tsv[3]


func _load_skill_data():
	var namedskill_resource := preload("res://card_data/named_skill_catalog.txt")
	var namedskills = namedskill_resource.text.split("\n")
	for s in namedskills:
		var csv = s.split("\t")
		var id := int(csv[0])
		var text = csv[5].replace("\\n","\n")
		_skill_catalog[id] = SkillData.NamedSkillData.new(id,csv[1],csv[2],csv[3],csv[4],text)

	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/named_skill_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/named_skill_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _skill_catalog[id] as SkillData.NamedSkillData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.text = tsv[3].replace("\\n","\n")

func _load_card_data():
	var carddata_resource := preload("res://card_data/card_data_catalog.txt")
	var cards = carddata_resource.text.split("\n")
	for c in cards:
		var csv = c.split("\t")
		var skills = []
		var skill_texts = csv[8].split(";")
		if skill_texts.size() == 1 and skill_texts[0] == "":
			skill_texts.resize(0)
		for s in skill_texts:
			var skill_line = s.split(":");
			var condition : int = int(skill_line[0])
			var base_data := get_skill_data(int(skill_line[1]))
			var params := []
			var skill_line_param : PoolStringArray = skill_line[2].split(",")
			for i in base_data.param_type.size():
				params.append(get_skill_param(base_data.param_type[i],skill_line_param[i]))
			var skill := SkillData.NamedSkill.new(base_data,condition,params)
			skills.append(skill)
		var id := int(csv[0])
		var text = csv[9].replace("\\n","\n")
		_card_catalog[id] = CardData.new(id,csv[1],csv[2],
				int(csv[3]),int(csv[4]),int(csv[5]),int(csv[6]),int(csv[7]),
				skills,text,csv[10])
	version = (_card_catalog[0] as CardData).name
# warning-ignore:return_value_discarded
	_card_catalog.erase(0)

	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/card_data_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/card_data_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _card_catalog[id] as CardData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.text = tsv[3].replace("\\n","\n")


