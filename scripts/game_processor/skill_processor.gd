extends Reference

class_name SkillProcessor

var named_skills := NamedSkillProcessor.new()

func _init():
	pass

func process_before(skills : Array,
		vs_color : int,link_color : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player):
	for s in skills:
		if s is SkillData.NormalSkill:
			NormalSkillProcessor.process_before(s,vs_color,link_color,myself,rival)
		elif s is SkillData.NamedSkill:
			named_skills.get_skill(s.id).process_before(s,
					vs_color,link_color,myself,rival)

func process_after(skills : Array,
		vs_color : int,link_color : int,situation : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player):
	for s in skills:
		if s is SkillData.NormalSkill:
			NormalSkillProcessor.process_after(s,vs_color,link_color,situation,myself,rival)
		elif s is SkillData.NamedSkill:
			named_skills.get_skill(s.id).process_after(s,
					vs_color,link_color,situation,myself,rival)

func process_end(skills : Array,
		vs_color : int,link_color : int,
		myself : ProcessorData.Player,
		rival : ProcessorData.Player):
	for s in skills:
		if s is SkillData.NormalSkill:
			NormalSkillProcessor.process_end(s,vs_color,link_color,myself,rival)
		elif s is SkillData.NamedSkill:
			named_skills.get_skill(s.id).process_end(s,
					vs_color,link_color,myself,rival)

