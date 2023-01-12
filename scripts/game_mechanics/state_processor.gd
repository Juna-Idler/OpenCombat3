
class_name StateProcessor



class Reinforce extends MechanicsData.BasicState:
	const STATE_ID = 1
	const PRIORITY = 1
	var _stats : CardData.Stats
	func _init(stats : CardData.Stats,container : Array).(container):
		_stats = stats

	func _before_priority() -> Array:
		return [PRIORITY]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var affected := myself._get_playing_card().affected
		affected.add(_stats)
		myself._append_effect_log(index,MechanicsData.EffectTiming.BEFORE,PRIORITY,true)
		remove_self()

	func _serialize() -> Array: # [id,fit_data]
		return [STATE_ID,_stats.to_array()]
