class_name MatchStatePerformer


func _init():
	pass


class ReinForce extends MatchEffect.BasicState:
	var stats : CatalogData.Stats
	func _init(state : CatalogData.StateData,data : Array,container : Array).(state,container):
		stats = CatalogData.Stats.new(data[0],data[1],data[2])
	
	func _before(_priority : int ,myself : MatchPlayer,_rival : MatchPlayer,_data) -> void:
		myself.combat_avatar.current_effect_line.succeeded()
		myself.add_attribute(stats.power,stats.hit,stats.block)
		myself.combat_avatar.play_sound(load("res://sound/ステータス上昇魔法2.mp3"))
		var tween = myself.combat_avatar.create_tween()
		tween.tween_interval(1.0)
		yield(tween,"finished")
		remove_self()

	func _get_caption() -> String:
		return _state.name + "(" + Global.card_catalog.stats_names.get_effect_string(stats) + ")"

	func _get_short_caption() -> String:
		return _state.name + "(" + Global.card_catalog.stats_names.get_short_effect_string(stats) + ")"

	func _get_description() -> String:
		var param := _state.parameter[0]
		return _state.text.replace("{" + param + "}",Global.card_catalog.stats_names.get_effect_string(stats))
