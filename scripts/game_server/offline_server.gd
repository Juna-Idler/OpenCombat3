extends IGameServer


var _game_processor : GameProcessor
var _player_name:String

var _cpu_commander
var _result:int

var card_catalog : CardCatalog

func _init(name:String,commander):
	initialize(name,commander)

func initialize(name:String,commander):
	_game_processor = GameProcessor.new(card_catalog)
	_player_name = name;
	_cpu_commander = commander;

func create_update_playerData(data) -> UpdateData.PlayerData:
	var d = UpdateData.PlayerData.new()
	return d;
#	return new UpdateData.PlayerData { draw = data.draw.ToArray(), select = data.select, deckcount = data.deck.Count };

func _get_initial_data() -> InitialData:
	return InitialData.new()
	
func _send_ready():
#	UpdateData.PlayerData p1 = CreateUpdatePlayerData(GameProcessor.Player1);
#	UpdateData.PlayerData p2 = CreateUpdatePlayerData(GameProcessor.Player2);
#	UpdateData p1update = new() { phase = 0, damage = 0, myself = p1, rival = p2 };
#	Result = Commander.FirstSelect(p2.draw,p1.draw);
	emit_signal("data_recieved", UpdateData.new())
#        Callback(p1update, null);

func _send_select(phase:int,index:int):
	pass

func _send_surrender():
#        Callback(new UpdateData() { damage = 1, }, "Surrender");
	pass

# このインターフェイスの破棄
func _terminalize():
	pass
