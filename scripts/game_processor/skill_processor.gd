extends Reference

class_name SkillProcessor

var named_skills := NamedSkillProcessor.new()

func _init():
	pass

func process_before(skills : Array,
		vs_color : int,link_color : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			named_skills.get_skill(s.data.id)._process_before(s,
					myself,rival)

func process_after(skills : Array,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			named_skills.get_skill(s.data.id)._process_after(s,
					situation,myself,rival)

func process_end(skills : Array,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorData.PlayerData,
		rival : ProcessorData.PlayerData):
	for s in skills:
		if s.test_condition(vs_color,link_color):
			named_skills.get_skill(s.data.id)._process_end(s,
					situation,myself,rival)

