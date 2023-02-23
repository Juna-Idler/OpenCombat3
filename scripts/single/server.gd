extends IGameServer

class_name SinglePlayerServer

var _processor := GameProcessor.new()
var _player_name:String

var _enemy_name:String


func _init():
	pass

func initialize(name:String,deck:Array,hand_count : int,card_catalog : I_CardCatalog,
		enemy_name : String,enemy_deck:Array,enemy_hand : int,enemy_hp : int,enemy_catalog : I_CardCatalog
		):
#		enemy_data : EnemyData):
	_player_name = name;
	_enemy_name = enemy_name

	
	var p1 := OfflinePlayer.new(deck,hand_count,card_catalog,true)
	var p2 := SinglePlayEnemy.new(enemy_deck,enemy_hand,enemy_hp,enemy_catalog,true)
# warning-ignore:return_value_discarded
	_processor.standby(p1,p2)

func _get_primary_data() -> PrimaryData:
	var my_deck_list = []
	for c in _processor.player1._get_deck_list():
		my_deck_list.append(c.data.id)
	var e_deck_list = []
	for c in _processor.player2._get_deck_list():
		e_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,
			_enemy_name,e_deck_list,
			null,null)


func _send_ready():
	var p1 := FirstData.PlayerData.new(_processor.player1._get_hand(),_processor.player1._get_life(),-1)
	var p2 := FirstData.PlayerData.new(_processor.player2._get_hand(),_processor.player2._get_life(),-1)
	var p1first := FirstData.new(p1,p2)
	emit_signal("recieved_first_data", p1first)


func _send_combat_select(round_count:int,index:int,hands_order:PoolIntArray = []):
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.COMBAT:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.combat(index,0)

	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
#	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()

	emit_signal("recieved_combat_result", p1update)


static func create_commander_player(player : MechanicsData.IPlayer) -> ICpuCommander.Player:
	return ICpuCommander.Player.new(player._get_hand(),player._get_played(),
			player._get_discard(),player._get_stock_count(),player._get_life(),
			player._get_next_effect().duplicate())
	


func _send_recovery_select(round_count:int,index:int,hands_order:PoolIntArray = []):
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.RECOVERY:
		return
	if not hands_order.empty():
		_processor.reorder_hand1(hands_order)

	_processor.recover(index,-1)

	var p1 := _create_update_playerData(_processor.player1)
	var p2 := _create_update_playerData(_processor.player2)
	var p1update := UpdateData.new(_processor.round_count,_processor.phase,_processor.situation,p1,p2)
#	var p2update := UpdateData.new(_processor.round_count,_processor.phase,-_processor.situation,p2,p1)
	_processor.reset_select()
	
	emit_signal("recieved_recovery_result", p1update)


func _send_surrender():
	emit_signal("recieved_end","You surrender")
	pass



static func _create_update_playerData(player : MechanicsData.IPlayer) -> UpdateData.PlayerData:
	var effect_log = []
	for sl in player._get_effect_log():
		var s := sl as MechanicsData.EffectLog
		effect_log.append(IGameServer.UpdateData.EffectLog.new(s.index,s.timing,s.priority,s.data))
	var p = IGameServer.UpdateData.PlayerData.new(player._get_playing_hand(),player._get_select(),effect_log,
			player._get_draw(),player._get_damage(),player._get_life(),-1)
	return p;
