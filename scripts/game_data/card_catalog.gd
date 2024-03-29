
extends I_CardCatalog

class_name CardCatalog

class StatsNames:
	var power : String
	var hit : String
	var block : String
	
	var short_power : String
	var short_hit : String
	var short_block : String

	var param_power : String
	var param_hit : String
	var param_block : String

	func get_effect_string(stats : CatalogData.Stats) -> String:
		var texts : PoolStringArray = []
		if stats.power != 0:
			texts.append(power + "%+d" % stats.power)
		if stats.hit != 0:
			texts.append(hit + "%+d" % stats.hit)
		if stats.block != 0:
			texts.append(block + "%+d" % stats.block)
		return texts.join(" ")
	
	func get_short_effect_string(stats : CatalogData.Stats) -> String:
		var texts : PoolStringArray = []
		if stats.power != 0:
			texts.append(short_power + "%+d" % stats.power)
		if stats.hit != 0:
			texts.append(short_hit + "%+d" % stats.hit)
		if stats.block != 0:
			texts.append(short_block + "%+d" % stats.block)
		return texts.join(" ")

	func create_stats_from_param_string(param : String) -> CatalogData.Stats:
		var r := CatalogData.Stats.new(0,0,0)
		for e in param.split(" "):
			if e.find(param_power) == 0:
				r.power = int(e.substr(param_power.length()))
			elif e.find(param_hit) == 0:
				r.hit = int(e.substr(param_hit.length()))
			elif e.find(param_block) == 0:
				r.block = int(e.substr(param_block.length()))
		return r



var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}

var _state_catalog : Dictionary = {}

var stats_names := StatsNames.new()


var version : String


func _init():
#	translation = TranslationServer.get_locale()
	
	load_catalog()

func load_catalog():
	_load_attribute_data()
	_load_state_data()
	_load_skill_data()
	_load_card_data()
	

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func _get_card_data(id : int) -> CatalogData.CardData:
	return _card_catalog[id]

	


func get_skill_data(id : int) -> CatalogData.SkillData:
	return _skill_catalog[id]

func get_state_data(id : int) -> CatalogData.StateData:
	return _state_catalog[id]

func get_skill_param(param_type : int,param : String) -> CatalogData.SkillParameter:
	match param_type:
		CatalogData.ParamType.INTEGER:
			return CatalogData.SkillParameter.new(param,param,int(param))
		CatalogData.ParamType.ATTRIBUTES:
			var stats = stats_names.create_stats_from_param_string(param)
			return CatalogData.SkillParameter.new(stats_names.get_effect_string(stats),stats_names.get_short_effect_string(stats),stats)
		CatalogData.ParamType.COLOR:
			var ColorName := [tr("NO_COLOR"),tr("RED"),tr("GREEN"),tr("BLUE")]
			return CatalogData.SkillParameter.new(ColorName[int(param)],ColorName[int(param)],int(param))
	return null
	



func _load_card_data():
	var carddata_resource := preload("res://card_data/card_data_catalog.txt")
	var cards = carddata_resource.text.split("\n")
	for c in cards:
		var tsv = c.split("\t")
		var skills = []
		var skill_texts = tsv[9].split(";")
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
			var skill := CatalogData.CardSkill.new(base_data,condition,params)
			skills.append(skill)
		var id := int(tsv[0])
		var text = tsv[10].replace("\\n","\n")
		var image = "res://card_images/"+ tsv[11] +".png"
		_card_catalog[id] = CatalogData.CardData.new(id,tsv[1],tsv[2],tsv[3],
				int(tsv[4]),int(tsv[5]),int(tsv[6]),int(tsv[7]),int(tsv[8]),
				skills,text,image)
	version = (_card_catalog[0] as CatalogData.CardData).name
# warning-ignore:return_value_discarded
	_card_catalog.erase(0)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/card_data_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/card_data_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _card_catalog[id] as CatalogData.CardData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			data.text = tsv[3].replace("\\n","\n")


func _load_skill_data():
	var namedskill_resource := preload("res://card_data/named_skill_catalog.txt")
	var namedskills = namedskill_resource.text.split("\n")
	for s in namedskills:
		var tsv = s.split("\t")
		var id := int(tsv[0])
		var text = tsv[7].replace("\\n","\n")

		var states_strings : PoolStringArray = tsv[6].split(",")
		var states : Array = []
		if not (states_strings.size() == 1 and states_strings[0].empty()):
			for i in states_strings:
				states.append(_state_catalog[int(i)])
		_skill_catalog[id] = CatalogData.SkillData.new(id,tsv[1],tsv[2],tsv[3],tsv[4],tsv[5],states,text)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/named_skill_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/named_skill_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _skill_catalog[id] as CatalogData.SkillData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			if not data.parameter.empty():
				data.parameter = tsv[3].split(",")
			data.text = tsv[4].replace("\\n","\n")

func _load_state_data():
	var state_resource := preload("res://card_data/state_catalog.txt")
	var states = state_resource.text.split("\n")
	for s in states:
		var tsv = s.split("\t")
		var id := int(tsv[0])
		var text = tsv[5].replace("\\n","\n")
		_state_catalog[id] = CatalogData.StateData.new(id,tsv[1],tsv[2],tsv[3],tsv[4],text)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/state_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/state_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _state_catalog[id] as CatalogData.StateData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			if not data.parameter.empty():
				data.parameter = tsv[3].split(",")
			data.text = tsv[4].replace("\\n","\n")



func _load_attribute_data():
	var attribute_resource = preload("res://card_data/attribute_catalog.txt")
	var attributes = attribute_resource.text.split("\n")
	for s in attributes:
		var tsv = s.split("\t")
		var id := int(tsv[0])
		match id:
			1:
				stats_names.param_power = tsv[1]
				stats_names.power = tsv[2]
				stats_names.short_power = tsv[3]
			2:
				stats_names.param_hit = tsv[1]
				stats_names.hit = tsv[2]
				stats_names.short_hit = tsv[3]
			3:
				stats_names.param_block = tsv[1]
				stats_names.block = tsv[2]
				stats_names.short_block = tsv[3]

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/attribute_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/attribute_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			match id:
				1:
					stats_names.power = tsv[1]
					stats_names.short_power = tsv[2]
				2:
					stats_names.hit = tsv[1]
					stats_names.short_hit = tsv[2]
				3:
					stats_names.block = tsv[1]
					stats_names.short_block = tsv[2]
