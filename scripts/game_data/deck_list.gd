
class_name DeckList


var file_path : String

var list : Array # of DeckData
var select : int = 0


func _init(path : String):
	file_path = path
# warning-ignore:return_value_discarded
	load_deck_list()


func get_select_deck():
	if select < 0 or select >= list.size():
		return null
	return list[select]


func save_deck_list():
	if select >= list.size():
		select = list.size()-1;
	if select < 0:
		select = 0

	var f = File.new()
	f.open(file_path, File.WRITE)
	f.store_csv_line(PoolStringArray([select]),"\t")
	for i in list:
		var item := i as DeckData
		var cards_text := PoolStringArray(Array(item.cards)).join(",")
		var keys_text := PoolStringArray(Array(item.key_cards)).join(",")
		f.store_csv_line(PoolStringArray([item.name,cards_text,keys_text]),"\t")
	f.close()
	
func load_deck_list() -> bool:
	var f = File.new()
	if not f.file_exists(file_path):
		return false
	list = []
	f.open(file_path, File.READ)
	var head = f.get_csv_line("\t")
	select = int(head[0])
	while (not f.eof_reached()):
		var line = f.get_csv_line("\t")
		if line.size() != 3:
			continue
		var tmp : PoolStringArray = line[1].split(",")
		var cards := PoolIntArray([] if tmp.size() == 1 and tmp[0] == "" else Array(tmp))
		tmp = line[2].split(",")
		var keys := PoolIntArray([] if tmp.size() == 1 and tmp[0] == "" else Array(tmp))
		list.append(DeckData.new(line[0],cards,keys))
	f.close()
	return true
	
