extends RPGH_DataManager
# Just keeps a value that is stored over multiple
# maps and sessions.

var value setget _set_value, _get_value

var _key = ""
var _initial_value = null
var _data

func _init(key: String, initial_value = null, map = null, event = null):
	_data = RPGH.get_node("DataManager").global_data
	_initial_value = initial_value
	var map_key = ""
	var event_key = ""
	if map != null:
		yield(map, "ready")
		map_key = map.name + "_"
	if event != null:
		event_key = event.name + "_"
	_key = map_key + event_key + key


func _set_value(new_value):
	if new_value == _initial_value:
		_data.erase(_key)
	else:
		RPGH.get_node("DataManager").write_in_dictionary(_key, new_value)


func _get_value():
	if _key in _data:
		return _data[_key]
	else:
		return _initial_value
