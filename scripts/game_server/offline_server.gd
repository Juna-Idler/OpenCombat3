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
	var edeck := [1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9]
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
	_result = _commander._first_select(p2.draw_indexes,p1.draw_indexes)
	emit_signal("recieved_first_data", p1first,null)


func _send_select(phase:int,index:int,hands_order:Array):
	var index2 = _result
	if phase & 1 == 0:
		_processor.combat(index,index2)
	else:
		if _processor.player1.is_recovery():
			_processor.recover2(index2)
		elif _processor.player2.is_recovery():
			_processor.recover1(index)
		else:
			_processor.recover_both(index,index2)

	var p = _processor.phase
	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new(p,p1,p2)
	var p2update := UpdateData.new(p,p2,p1)
	_processor.reset_select()
	
	if p & 1 == 0:
		_result = _commander._combat_select(p2update);
	else:
		if not _processor.player2.is_recovery():
			_result = _commander._recover_select(p2update)
	
	emit_signal("recieved_update_data", p1update,null)

#	if _processor.phase & 1 == 1 and _processor.player1.is_recovery() and not processor.player2.is_recovery():
#		_send_select(_processor.phase,-1,[])


func _send_surrender():
	emit_signal("recieved_abort",-1,"Surrender")
	pass

# このインターフェイスの破棄
func _terminalize():
	pass



func _create_update_playerData(player : ProcessorData.Player) -> UpdateData.PlayerData:
	var affecteds = []
	for c in player.deck_list:
		var a := (c as ProcessorData.PlayerCard).affected
		if a.updated:
			affecteds.append(UpdateData.Affected.new((c as ProcessorData.PlayerCard).id_in_deck,
					a.power,a.hit,a.damage,a.rush))
	var n := player.next_effect
	var next = UpdateData.Affected.new(0,n.power,n.hit,n.damage,n.rush)
	var p = UpdateData.PlayerData.new(
			player.hand_indexes,
			player.select,
			affecteds,
			next,
			player.draw_indexes,
			player.battle_damage,
			player.get_life())
	return p;
