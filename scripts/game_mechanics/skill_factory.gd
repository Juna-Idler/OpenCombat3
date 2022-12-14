
class_name SkillFactory

extends MechanicsData.ISkillFactory


const skills : Array = [
	null,
	SkillProcessor.Reinforce,
	SkillProcessor.Pierce,
	SkillProcessor.Charge,
	SkillProcessor.Isolate,
	SkillProcessor.Absorb,
]

func _create(skill : SkillData.NamedSkill) -> MechanicsData.ISkill:
	return skills[skill.data.id].new(skill)
