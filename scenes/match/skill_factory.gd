
class_name MatchCardSkillFactory

extends MatchEffect.ISkillFactory


const skills : Array = [
	null,
	MatchSkillPerformer.Reinforce,
	MatchSkillPerformer.Pierce,
	MatchSkillPerformer.Charge,
	MatchSkillPerformer.Isolate,
	MatchSkillPerformer.Absorb,
]

func _create(skill : SkillData.NamedSkill) -> MatchEffect.ISkill:
	return skills[skill.data.id].new(skill)
