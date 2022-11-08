
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
			var cd := catalog.get_card_data(id)
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
	
	var hand_count : int
	
	var thinking_time : float
	var combat_additional_time : float
	var recovery_additional_time : float
	

	

