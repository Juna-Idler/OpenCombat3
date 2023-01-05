
class_name StateProcessor



class Reinforce extends MechanicsData.BasicState:
	const PRIORITY = 1
	var power: int
	var hit : int
	var block : int
	func _init(p : int,h : int,b : int,container : Array).(container):
		power = p
		hit = h
		block = b

	func _before_priority() -> Array:
		return [PRIORITY]
	func _process_before(index : int,_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> void:
		var affected := myself._get_playing_card().affected
		affected.add(power,hit,block)
		myself._append_effect_log(index,MechanicsData.EffectTiming.BEFORE,PRIORITY,true)
