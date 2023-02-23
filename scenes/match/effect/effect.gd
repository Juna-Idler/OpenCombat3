
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
	func _create(_skill : CatalogData.CardSkill) -> ISkill:
		return null


class IState extends IEffect:
	func _get_caption() -> String:
		return ""
	func _get_short_caption() -> String:
		return ""
	func _get_description() -> String:
		return ""

class BasicState extends IState:
	var _state : CatalogData.StateData
	var _container : Array
	func _init(state : CatalogData.StateData,container : Array):
		_state = state
		_container = container
		_container.append(self)

	func remove_self() -> void:
		_container.erase(self)


class IStateDeserializer:
	func _deserialize(_id : int,_data,_container : Array) -> IState:
		return null

