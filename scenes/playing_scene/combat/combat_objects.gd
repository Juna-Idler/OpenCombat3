extends Node

class_name CombatObjects

onready var avatar : CombatAvatar = $Avatar

onready var skills := [$SkillList/Skill1, $SkillList/Skill2,$SkillList/Skill3,$SkillList/Skill4]

onready var power : Label = $Power
onready var hit : Label = $Hit
onready var block : Label = $Block

func _ready():
	pass
