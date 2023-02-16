
class_name MatchCardSkillFactory

extends MatchEffect.ISkillFactory


const skills : Array = [
	null,
	MatchSkillPerformer.Reinforce,
	MatchSkillPerformer.Pierce,
	MatchSkillPerformer.Charge,
	MatchSkillPerformer.Isolate,
	MatchSkillPerformer.Absorb,
	MatchSkillPerformer.BlowAway,
	MatchSkillPerformer.Attract,
]

func _create(skill : CatalogData.CardSkill) -> MatchEffect.ISkill:
	return skills[skill.data.id].new(skill)
