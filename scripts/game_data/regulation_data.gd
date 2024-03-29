
class_name RegulationData

class DeckRegulation:
	var name : String
	 # カード総数
	var card_count : int
	 # カード総コスト
	var total_cost : int

	 # レベルごとのカード数制限
	var level2_limit : int
	var level3_limit : int

	 # 使用可能なカードのID 二つのintで範囲（両端含む）を表す
	var card_pool : PoolIntArray #of int [1,27,28,30] id 1-27 and id 28-30

	func _init(n:String,cc:int,tc:int,l2l:int,l3l:int,cp_string : String):
		name = n
		card_count = cc
		total_cost = tc
		level2_limit = l2l
		level3_limit = l3l

		var cp := cp_string.split(" ")
		card_pool.resize(cp.size() * 2)
		for i in cp.size():
			var r = (cp[i] as String).split("-")
			if r.size() == 1:
				card_pool[i*2] = int(r[0])
				card_pool[i*2+1] = card_pool[i*2]
			else:
				card_pool[i*2] = int(r[0])
				card_pool[i*2+1] = int(r[1])

	static func create(regulation : String,n : String = "") -> DeckRegulation:
		var p = regulation.split("/")
		if p.size() != 5:
			return null
		return DeckRegulation.new(n,int(p[0]),int(p[1]),int(p[2]),int(p[3]),p[4])
		
	func to_regulation_string() -> String:
		return "%s/%s/%s/%s/%s" % [card_count,total_cost,level2_limit,level3_limit,card_pool_string()]

	func card_pool_string():
		var cp : PoolStringArray = []
# warning-ignore:integer_division
		for i in card_pool.size()/2:
			if card_pool[i*2] == card_pool[i*2+1]:
				cp.append(str(card_pool[i*2]))
			else:
				cp.append("%s-%s" % [card_pool[i*2],card_pool[i*2+1]])
		return cp.join(" ")

	enum Regulation_Failed {
		CARD_COUNT,
		TOTAL_COST,
		LEVEL2_LIMIT,
		LEVEL3_LIMIT,
		MULTIPLE_LIMIT,
		CARD_POOL,
	}

	func check_regulation(deck : Array,catalog : CardCatalog) -> Array:
		var failed := []

		if deck.size() != card_count:
			failed.append(Regulation_Failed.CARD_COUNT)
		
		var cost := 0
		var level2_count := 0
		var level3_count := 0
		var same_card_count := {}
		for id in deck:
			if not _check_card_pool(id):
				failed.append(Regulation_Failed.CARD_POOL)
			var cd := catalog._get_card_data(id)
			cost += cd.level
			level2_count += 1 if cd.level == 2 else 0
			level3_count += 1 if cd.level == 3 else 0
			if not same_card_count.has(id):
				same_card_count[id] = 1
			else:
				var same_count = same_card_count[id] + 1
				same_card_count[id] = same_count
				if ((cd.level == 1 and same_count > 3) or
						(cd.level == 2 and same_count > 2) or
							cd.level == 3):
					failed.append(Regulation_Failed.MULTIPLE_LIMIT)

		if cost >total_cost:
			failed.append(Regulation_Failed.TOTAL_COST)
		if level2_count > level2_limit:
			failed.append(Regulation_Failed.LEVEL2_LIMIT)
		if level3_count > level3_limit:
			failed.append(Regulation_Failed.LEVEL3_LIMIT)
			
		return failed


	func _check_card_pool(id : int)->bool:
		for i in range(0,card_pool.size(),2):
			if card_pool[i] <= id and id <= card_pool[i + 1]:
				return true
		return false


class MatchRegulation:
	var name : String
	
	var hand_count : int
	
	var thinking_time : float
	var combat_time : float
	var recovery_time : float
	
	func _init(n:String,hc:int,tt:float,ct:float,rt:float):
		name = n
		hand_count = hc
		thinking_time = tt
		combat_time = ct
		recovery_time = rt

	static func create(regulation : String,n : String = "") -> MatchRegulation:
		var p = regulation.split("/")
		if p.size() < 4:
			return null
		return MatchRegulation.new(n,int(p[0]),float(p[1]),float(p[2]),float(p[3]))
	
	func to_regulation_string() -> String:
		return "%s/%s/%s/%s" % [hand_count,thinking_time,combat_time,recovery_time]

	

