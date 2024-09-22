class_name RPGH_Event, "res://addons/rpgh_engine/nodes/event/icon_event.svg"
extends Node
# This is the main class for interacting with the RPGH Engine's
# core system. Adds behaviour to the game.

signal triggered

export(bool) var auto_start = false
export(bool) var block_player = true

var map: RPGH_Map = RPGH.get_node("DataManager").current_map
var state setget _set_state, _get_state

var _state := Storable("State")
var _is_first_run := Storable("IsFirstRun", true)


func _ready():
	if auto_start:
		_run()


func is_first_run() -> bool:
	return _is_first_run.value 


# This function currently simply plays the event without further
# preparations or clean up. So that the event can be called
# within another one.
#
# TODO: automate this somehow please :pray:
func append():
	var filtered_state_value = "default" if _state.value == null else _state.value
	var func_state = call(filtered_state_value)
	if func_state is GDScriptFunctionState:
		yield(func_state, "completed")
	_is_first_run.value = false


# --- INGAME_CAMERA -----------------------------------------------------------


func set_camera_setup(camera_setup):
	RPGH.Camera.set_camera_setup(camera_setup)


func fade_over_camera_setup(camera_setup, duration, smooth = false):
	RPGH.Camera.fade_over_camera_setup(camera_setup, duration, smooth)


func CameraSetup():
	return RPGH.Camera.CameraSetup.new()


# --- UI_DIALOG --------------------------------------------------------------- 


func textbox(id: String, left_bust: Texture = null, right_bust: Texture = null):
	RPGH.Dialog.textbox(id, left_bust, right_bust)


func screen_text(id: String):
	RPGH.Dialog.screen_text(id)


func close_textbox():
	var func_state = RPGH.Dialog.close_textbox()
	if func_state is GDScriptFunctionState:
		yield(func_state, "completed")
	if !block_player:
		_enable_character_movement()


# -----------------------------------------------------------------------------

func _run():
	emit_signal("triggered")
	if block_player:
		RPGH.Player._player_movement_disabled = true
		RPGH.Player._player_interact_disabled = true
	var filtered_state_value = "default" if _state.value == null else _state.value
	var func_state = call(filtered_state_value)
	if func_state is GDScriptFunctionState:
		yield(func_state, "completed")
	close_textbox()
	_is_first_run.value = false
	_enable_character_movement()


func _enable_character_movement():
	RPGH.Player._player_movement_disabled = false
	yield(RPGH.get_tree(), "physics_frame")
	yield(RPGH.get_tree(), "physics_frame")
	RPGH.Player._player_interact_disabled = false


func _set_state(new_state):
	if !new_state is String:
		push_error("State can only be set to string.")
		return
	_state.value = new_state


func _get_state():
	return _state.value


# Just a fast wrapper for "storable.gd".
class RPGH_Storable:
	extends "res://addons/rpgh_engine/system/data_management/storable.gd"
	func _init(key: String, value = null, map = null, event = null).(key, value, map, event): pass
func Storable(key: String, value = null) -> RPGH_Storable:
	return RPGH_Storable.new(name + key, value, map, self)
