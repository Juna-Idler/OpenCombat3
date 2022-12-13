
class_name MatchLogList

const FILE_VERSION = "Ver.first_time"

var file_path : String

var list := []


func _init(path : String):
	file_path = path
# warning-ignore:return_value_discarded
	load_list()

func append(match_log : MatchLog):
	list.append(match_log)

func save_list():
	var save_dic = {
		"version":FILE_VERSION,
		"list":[]
	}
	var log_list = []
	for i in list:
		log_list.append(i.to_json_dictionary())
	save_dic["list"] = log_list
	var f = File.new()
	f.open(file_path, File.WRITE)
	f.store_string(JSON.print(save_dic))
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
	
	if not json.result.has("version") or json.result["version"] != FILE_VERSION:
		return false

	list = []
	for i in json.result["list"]:
		var ml = MatchLog.new()
		ml.from_json_dictionary(i)
		list.append(ml)
	return true
	
