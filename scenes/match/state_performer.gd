class_name MatchStatePerformer


func _init():
	pass


class ReinForce extends MatchEffect.BasicState:
	var power : int
	var hit : int
	var block : int
	func _init(state : StateData.PlayerStateData,data : Array,container : Array).(state,container):
		power = data[0]
		hit = data[1]
		block = data[2]
	
	func _before(_priority : int ,myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		myself.combat_avatar.current_effect_line.succeeded()
		myself.add_attribute(power,hit,block)
		myself.combat_avatar.play_sound(load("res://sound/ステータス上昇魔法2.mp3"))
		var tween = myself.combat_avatar.create_tween()
		tween.tween_interval(1.0)
		yield(tween,"finished")
		remove_self()

	func _get_caption() -> String:
		_state.name
		return ""
	func _get_short_caption() -> String:
		return ""
	func _get_description() -> String:
		return ""
