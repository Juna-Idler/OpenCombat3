extends IGameServer

class_name OfflineServer

var _processor := GameProcessor.new()
var _player_name:String

var _commander : ICpuCommander = null
var _result:int



func _init():
	pass

func initialize(name:String,deck:Array,
		commander : ICpuCommander,cpu_deck:Array,
		regulation :RegulationData.MatchRegulation,card_catalog : CardCatalog):
	_player_name = name;
	_commander = commander
	
	var p1 := OfflinePlayer.new(deck,regulation.hand_count,card_catalog,true)
	var p2 := OfflinePlayer.new(cpu_deck,regulation.hand_count,card_catalog,true)
# warning-ignore:return_value_discarded
	_processor.standby(p1,p2)

func _get_primary_data() -> PrimaryData:
	var my_deck_list = []
	for c in _processor.player1._get_deck_list():
		my_deck_list.append(c.data.id)
	var r_deck_list = []
	for c in _processor.player2._get_deck_list():
		r_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,
			_commander._get_commander_name(),r_deck_list,"")
	
func _send_ready():
	var p1 := FirstData.PlayerData.new(_processor.player1._get_hand(),_processor.player1._get_life())
	var p2 := FirstData.PlayerData.new(_processor.player2._get_hand(),_processor.player2._get_life())
	var p1first := FirstData.new(p1,p2)
	_result = _commander._first_select(p2.hand,p1.hand)
	emit_signal("recieved_first_data", p1first)


func _send_combat_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	var index2 = _result
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.COMBAT:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.combat(index,index2)

	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()

	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(p2update);
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(p2update)
		else:
			_result = -1
	emit_signal("recieved_combat_result", p1update)


func _send_recovery_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	var index2 = _result
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.RECOVERY:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.recover(index,index2)

	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()
	
	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(p2update);
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(p2update)
		else:
			_result = -1
	emit_signal("recieved_recovery_result", p1update)


func _send_surrender():
	emit_signal("recieved_end","You surrender")
	pass



static func _create_update_playerData(player : MechanicsData.IPlayer) -> UpdateData.PlayerData:
	var skilllog = []
	for sl in player._get_skill_log():
		var s := sl as MechanicsData.SkillLog
		skilllog.append(IGameServer.UpdateData.SkillLog.new(s.index,s.timing,s.priority,s.data))
	var p = IGameServer.UpdateData.PlayerData.new(player._get_playing_hand(),player._get_select(),skilllog,
			player._get_draw(),player._get_damage(),player._get_life())
	return p;
