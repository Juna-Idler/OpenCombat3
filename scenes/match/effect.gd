
class_name MatchEffect


class IEffect:
	func _before(_priority : int,_myself,_rival,_data) -> void:
		return
	func _engaged(_priority:int,situation : int,_myself,_rival,_data) -> int:
		return situation
	func _after(_priority:int,_situation : int,_myself,_rival,_data) -> void:
		return
	func _end(_priority:int,_situation : int,_myself,_rival,_data) -> void:
		return


class ISkill extends IEffect:
	pass


class ISkillFactory:
	func _create(_skill : SkillData.NamedSkill) -> ISkill:
		return null


class IState extends IEffect:
	func _serialize() -> String:
		return ""

class BasicState extends IState:
	var _container : Array
	func _init(container : Array):
		_container = container
		_container.append(self)

	func _remove_self() -> void:
		_container.erase(self)

class IStateFactory:
	func _create() -> IState:
		return null

