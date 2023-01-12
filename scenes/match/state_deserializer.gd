
extends MatchEffect.IStateDeserializer

class_name StateDeserializer

const states := [
	null,
	MatchStatePerformer.ReinForce,
]


func _deserialize(id : int,data,container : Array) -> MatchEffect.IState:
	return states[id].new(data,container)


