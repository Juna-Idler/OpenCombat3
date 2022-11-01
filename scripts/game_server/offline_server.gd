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
	edeck.shuffle()
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
			_commander._get_commander_name(),r_deck_list,"")
	
func _send_ready():
	var p1 := FirstData.PlayerData.new(_processor.player1.hand,_processor.player1.get_life())
	var p2 := FirstData.PlayerData.new(_processor.player2.hand,_processor.player2.get_life())
	var p1first := FirstData.new(p1,p2)
	_result = _commander._first_select(p2.hand,p1.hand)
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
	var p1update := UpdateData.new(round_count,phase,_processor.situation,p1,p2)
	var p2update := UpdateData.new(round_count,phase,-_processor.situation,p2,p1)
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
	var p1update := UpdateData.new(round_count,phase,_processor.situation,p1,p2)
	var p2update := UpdateData.new(round_count,phase,-_processor.situation,p2,p1)
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



static func _create_update_playerData(player : ProcessorPlayerData) -> UpdateData.PlayerData:
	var updates = []
	for c in player.deck_list:
		var a := (c as ProcessorData.PlayerCard).affected
		if a.updated:
			var u := IGameServer.UpdateData.Updated.new([
					(c as ProcessorData.PlayerCard).id_in_deck,
					(c as ProcessorData.PlayerCard).data.id,
					a.power,a.hit,a.block])
			updates.append(u)
	var n := player.next_effect
	var hand := player.hand.duplicate()
	hand.insert(player.select,player.select_card.id_in_deck)
	hand.resize(hand.size() - player.draw_indexes.size())
	var p = IGameServer.UpdateData.PlayerData.new(hand,player.select,updates,
			n.power,n.hit,n.block,player.draw_indexes,player.damage,player.get_life())
	return p;
