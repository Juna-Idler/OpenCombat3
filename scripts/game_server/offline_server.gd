extends IGameServer

class_name OfflineServer

var _processor : GameProcessor = null
var _player_name:String

var _commander : ICpuCommander = null
var _result:int


class ZeroCommander extends ICpuCommander:
	func _get_commander_name()-> String:
		return "ZeroCommander"
	

func _init(name:String,card_catalog : CardCatalog):
	initialize(name,card_catalog)

func initialize(name:String,card_catalog):
	_processor = GameProcessor.new(card_catalog)
	_player_name = name;

func standby_single(deck:Array,enemy_id:int) -> bool:
	var edeck := []
	for i in 27:
		edeck.append(i + 1)
	_commander = ZeroCommander.new()
	_processor.standby(deck,4,true,edeck,1,false)
	return true

func _get_primary_data() -> PrimaryData:
	var my_deck_list = []
	for c in _processor.player1.deck_list:
		my_deck_list.append(c.data.id)
	var r_deck_list = []
	for c in _processor.player2.deck_list:
		r_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,
			_commander._get_commander_name(),r_deck_list)
	
func _send_ready():
	var p1 := FirstData.PlayerData.new(_processor.player1.hand_indexes,_processor.player1.get_life())
	var p2 := FirstData.PlayerData.new(_processor.player2.hand_indexes,_processor.player2.get_life())
	var p1first := FirstData.new(p1,p2)
	_result = _commander._first_select(p2.hand_indexes,p1.hand_indexes)
	emit_signal("recieved_first_data", p1first)


func _send_combat_select(round_count:int,index:int,hands_order:Array = []):
	var index2 = _result
	if int(_processor.phase / 2) + 1 != round_count:
		return
	if _processor.phase & 1 != 0:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.combat(index,index2)

	var phase : int = (Phase.GAMEFINISH if _processor.phase < 0
			else Phase.COMBAT if _processor.phase & 1 == 0
			else Phase.RECOVERY)
	if phase == Phase.COMBAT:
		round_count += 1

	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new()
	p1update.round_count = round_count
	p1update.next_phase = phase
	p1update.myself = p1
	p1update.rival = p2
	var p2update := UpdateData.new()
	p2update.round_count = round_count
	p2update.next_phase = phase
	p2update.myself = p2
	p2update.rival = p1
	_processor.reset_select()

	if phase == Phase.COMBAT:
		_result = _commander._combat_select(p2update);
	elif phase == Phase.RECOVERY:
		if not _processor.player2.is_recovery():
			_result = _commander._recover_select(p2update)
	emit_signal("recieved_combat_result", p1update,_processor.situation)


func _send_recovery_select(round_count:int,index:int,hands_order:Array = []):
	var index2 = _result
	if int(_processor.phase / 2) + 1 != round_count:
		return
	if _processor.phase & 1 == 0:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.recover(index,index2)

	var phase : int = (Phase.GAMEFINISH if _processor.phase < 0
			else Phase.COMBAT if _processor.phase & 1 == 0
			else Phase.RECOVERY)
	if phase == Phase.COMBAT:
		round_count += 1
	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new()
	p1update.round_count = round_count
	p1update.next_phase = phase
	p1update.myself = p1
	p1update.rival = p2
	var p2update := UpdateData.new()
	p2update.round_count = round_count
	p2update.next_phase = phase
	p2update.myself = p2
	p2update.rival = p1
	_processor.reset_select()
	
	if phase == Phase.COMBAT:
		_result = _commander._combat_select(p2update);
	elif phase == Phase.RECOVERY:
		if not _processor.player2.is_recovery():
			_result = _commander._recover_select(p2update)
	emit_signal("recieved_recovery_result", p1update)


func _send_surrender():
	emit_signal("recieved_abort",-1,"Surrender")
	pass

# このインターフェイスの破棄
func _terminalize():
	pass



static func _create_update_playerData(player : ProcessorData.PlayerData) -> UpdateData.PlayerData:
	var affecteds = []
	for c in player.deck_list:
		var a := (c as ProcessorData.PlayerCard).affected
		if a.updated:
			var ua := IGameServer.UpdateData.Affected.new()
			ua.id = (c as ProcessorData.PlayerCard).id_in_deck
			ua.power = a.power
			ua.hit = a.hit
			ua.damage = a.damage
			ua.rush = a.rush
			affecteds.append(ua)
	var n := player.next_effect
	var next = IGameServer.UpdateData.Affected.new()
	next.id = 0
	next.power = n.power
	next.hit = n.hit
	next.damage = n.damage
	next.rush = n.rush
	var p = IGameServer.UpdateData.PlayerData.new()
	p.hand_indexes = player.hand_indexes.duplicate()
	p.hand_indexes.insert(player.select,player.select_card.id_in_deck)
	p.hand_indexes.resize(p.hand_indexes.size() - player.draw_indexes.size())
	p.hand_select = player.select
	p.cards_update = affecteds
	p.next_effect = next
	p.draw_indexes = player.draw_indexes
	p.damage = player.battle_damage
	p.life = player.get_life()
	return p;
