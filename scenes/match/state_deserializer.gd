
extends MatchEffect.IStateDeserializer

class_name StateDeserializer

const states := [
	null,
	MatchStatePerformer.ReinForce,
]


func _deserialize(state : StateData.PlayerStateData,data,container : Array) -> MatchEffect.IState:
	return states[state.id].new(data,container)


