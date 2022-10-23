
class_name DeckList


var list : Array
var selected : int

func _init():
	load_deck_list()

const file_path := "user://deck_list.json"



func save_deck_list():
	var f = File.new()
	f.open(file_path, File.WRITE)
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
	while (not f.eof_reached()):
		var line = f.get_csv_line("\t")
		if line.size() != 3:
			continue
		var cards := PoolIntArray(Array(line[1].split(",")))
		var keys := PoolIntArray(Array(line[2].split(",")))
		list.append(DeckData.new(line[0],cards,keys))
	return true
	
