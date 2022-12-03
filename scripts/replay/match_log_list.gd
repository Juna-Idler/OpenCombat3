
class_name MatchLogList

var file_path : String

var list := []


func _init(path : String):
	file_path = path
# warning-ignore:return_value_discarded
	load_list()

func append(match_log : MatchLog):
	list.append(match_log)

func save_list():
	var dic_list = []
	for i_ in list:
		var i := i_ as MatchLog
		dic_list.append(i.to_json_dictionary())
	var f = File.new()
	f.open(file_path, File.WRITE)
	f.store_string(JSON.print(dic_list))
	f.close()
	
func load_list() -> bool:
	var f = File.new()
	if not f.file_exists(file_path):
		return false
	f.open(file_path, File.READ)
	var json = JSON.parse(f.get_as_text())
	f.close()
	if json.error != OK:
		return false
	
	list = []
	for i in json.result:
		var ml = MatchLog.new()
		ml.from_json_dictionary(i)
		list.append(ml)
	return true
	
