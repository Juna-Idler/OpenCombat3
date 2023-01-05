extends IGameServer

class_name OfflineServer

const COMBAT_RESULT_DELAY = 5000
const COMBAT_SKILL_DELAY = 1000
const RECOVER_RESULT_DELAY = 1000


var _processor := GameProcessor.new()
var _player_name:String

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var _commander : ICpuCommander = null
var _result:int

var _player_time : int
var _emit_time : int
var _delay_time : int


func _init():
	pass

func initialize(name:String,deck:Array,
		commander : ICpuCommander,cpu_deck:Array,
		d_regulation :RegulationData.DeckRegulation,
		m_regulation :RegulationData.MatchRegulation,card_catalog : CardCatalog):
	_player_name = name;
	_commander = commander
	commander._set_deck_list(PoolIntArray(cpu_deck),PoolIntArray(deck))

	deck_regulation = d_regulation
	match_regulation = m_regulation
	
	var p1 := OfflinePlayer.new(deck,m_regulation.hand_count,card_catalog,true)
	var p2 := OfflinePlayer.new(cpu_deck,m_regulation.hand_count,card_catalog,true)
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
			_commander._get_commander_name(),r_deck_list,
			deck_regulation,match_regulation)

func _send_ready():
	var p1 := FirstData.PlayerData.new(_processor.player1._get_hand(),
			_processor.player1._get_life(),match_regulation.thinking_time)
	var p2 := FirstData.PlayerData.new(_processor.player2._get_hand(),
			_processor.player2._get_life(),-1)
	var p1first := FirstData.new(p1,p2)
	_result = _commander._first_select(p2.hand,p1.hand)
	
	_emit_time = Time.get_ticks_msec()
	emit_signal("recieved_first_data", p1first)
	_player_time = int(match_regulation.thinking_time * 1000)
	_delay_time = int(match_regulation.combat_time * 1000) + 1000



func _send_combat_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	var elapsed = Time.get_ticks_msec() - _emit_time
	if elapsed > _delay_time:
		_player_time -= elapsed - _delay_time
		if _player_time < 0:
#			index = 0
#			hands_order = []
			_player_time = 0

	var index2 = _result
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.COMBAT:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.combat(index,index2)

	var p1 := _create_update_playerData(_processor.player1,_player_time / 1000.0)
	var p2 := _create_update_playerData(_processor.player2,-1)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
#	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()

	var skill_count := p1.effect_logs.size() + p2.effect_logs.size()
	_delay_time = skill_count * COMBAT_SKILL_DELAY + COMBAT_RESULT_DELAY
	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(create_commander_player(_processor.player2),
				create_commander_player(_processor.player1));
		_delay_time += int(match_regulation.combat_time * 1000)
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(create_commander_player(_processor.player2),
					create_commander_player(_processor.player1))
		else:
			_result = -1
		_delay_time += int(match_regulation.recovery_time * 1000)
	_emit_time = Time.get_ticks_msec()
	emit_signal("recieved_combat_result", p1update)


static func create_commander_player(player : MechanicsData.IPlayer) -> ICpuCommander.Player:
	return ICpuCommander.Player.new(player._get_hand(),player._get_played(),
			player._get_discard(),player._get_stock_count(),player._get_life(),
			player._get_next_effect().duplicate())
	


func _send_recovery_select(round_count:int,index:int,hands_order:PoolIntArray = []):
	if index >= 0:
		var elapsed = Time.get_ticks_msec() - _emit_time
		if elapsed > _delay_time:
			_player_time -= elapsed - _delay_time
			if _player_time < 0:
#				index = 0
#				hands_order = []
				_player_time = 0
	
	var index2 = _result
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.RECOVERY:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.recover(index,index2)

	var p1 := _create_update_playerData(_processor.player1,_player_time / 1000.0)
	var p2 := _create_update_playerData(_processor.player2,-1)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
#	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()
	
	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(create_commander_player(_processor.player2),
				create_commander_player(_processor.player1));
		_delay_time = int(match_regulation.combat_time * 1000) + RECOVER_RESULT_DELAY
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(create_commander_player(_processor.player2),
					create_commander_player(_processor.player1))
		else:
			_result = -1
		_delay_time = int(match_regulation.recovery_time * 1000) + RECOVER_RESULT_DELAY
			
	_emit_time = Time.get_ticks_msec()
	emit_signal("recieved_recovery_result", p1update)


func _send_surrender():
	emit_signal("recieved_end","You surrender")
	pass



static func _create_update_playerData(player : MechanicsData.IPlayer,time : float) -> UpdateData.PlayerData:
	var effect_log = []
	for sl in player._get_effect_log():
		var s := sl as MechanicsData.EffectLog
		effect_log.append(IGameServer.UpdateData.EffectLog.new(s.index,s.timing,s.priority,s.data))
	var p = IGameServer.UpdateData.PlayerData.new(player._get_playing_hand(),player._get_select(),effect_log,
			player._get_draw(),player._get_damage(),player._get_life(),time)
	return p;
