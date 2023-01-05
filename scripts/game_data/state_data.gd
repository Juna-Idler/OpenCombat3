
class_name StateData


class PlayerStateData:
	var id : int
	var name : String
	var short_name : String
	var parameter : PoolStringArray
	var text : String
	
	func _init(i:int,n:String,sn:String,p:String,t:String):
		id = i
		name = n
		short_name = sn
		if p.empty():
			parameter = []
		else:
			parameter = p.split(",")
		text = t
