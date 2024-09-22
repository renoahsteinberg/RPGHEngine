class_name RPGH_DataManager
extends Node


var current_map = null
var game_version: String

var _game_data = "user://save.json"

var default_data = {
	"options": {
		"music_volume": 0.5
	}
}

var global_data = {}


func _ready():
	load_from_file()
	game_version = ProjectSettings.get_setting("application/config/version")
	print(game_version)


func write_in_dictionary(key, value):
	global_data[key] = value


func save_to_file():
	var f = File.new()
	f.open(_game_data, File.WRITE)
	f.store_line(to_json(global_data))
	f.close()


func load_from_file():
	var f = File.new()
	if !f.file_exists(_game_data):
		default_data()
		return
	if f.open(_game_data, File.READ) != OK:
		f.close()
		return
	var text := JSON.parse(f.get_as_text())
	if text.result == null:
		default_data()
		push_error("Can't parse JSON, Save File is corrupted")
		return
	f.close()
	global_data = text.result


func default_data():
	global_data = default_data


func _on_Button_button_down():
	save_to_file()
