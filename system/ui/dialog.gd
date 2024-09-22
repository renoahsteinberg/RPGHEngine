extends Control

signal finished_textbox_queue

var _is_left_bust_visible = false
var _is_right_bust_visible = false
var _are_textboxes_cached = false
var _textbox_queue := []
var _current_textbox: RPGH_Textbox = null

var text_data = _json_parser()
var json_directory = _json_directory()

onready var Textbox = get_node("Textbox")
onready var DialogAnimationPlayer = get_node("AnimationPlayer")
onready var LeftBust = get_node("LeftBust")
onready var LeftBustAnimationPlayer = get_node("LeftBust/AnimationPlayer")
onready var RightBust = get_node("RightBust")
onready var RightBustAnimationPlayer = get_node("RightBust/AnimationPlayer")


func _json_directory(): # On Work
	var directory = Directory.new()
	if !directory.dir_exists("res://game/lang"):
		directory.make_dir("res://game/lang")
	return directory


func _json_parser():
	var text_data_file = File.new()
	text_data_file.open("res://game/lang/lang.json", File.READ)
	var text_data_json = JSON.parse(text_data_file.get_as_text())
	text_data_file.close()
	return text_data_json.result


func textbox(id: String, left_bust: Texture = null, right_bust: Texture = null):
	var textbox = RPGH_DefaultTextbox.new()
	var text = text_data[id].eng
	var name = text_data[id].name
	textbox.text = name + "\n" + text
	if !left_bust == null:
		textbox.left_artwork = left_bust
	if !right_bust == null:
		textbox.right_artwork = right_bust
	
	var is_no_textbox_opened = _current_textbox == null
	_textbox_queue.append(textbox)
	if is_no_textbox_opened:
		_show_textbox_queue()


func screen_text(id: String):
	var screen_text = RPGH_ScreenText.new()
	var text = text_data[id].eng
	screen_text.text = text
	
	var is_no_textbox_opened = _current_textbox == null
	_textbox_queue.append(screen_text)
	if is_no_textbox_opened:
		_show_textbox_queue()


func close_textbox():
	if !_current_textbox == null:
		_current_textbox._close()


func _show_textbox_queue():
	var is_queue_active = true
	
	while is_queue_active:
		var previous_textbox = _current_textbox
		_current_textbox = _textbox_queue.pop_front()
		var different_textbox_type
		
		if previous_textbox == null or _current_textbox == null:
			different_textbox_type = true
		else:
			different_textbox_type = !previous_textbox.type == _current_textbox.type
		
		if different_textbox_type and !previous_textbox == null:
			previous_textbox._close()
			yield(previous_textbox, "closed_textbox")
			
		if !_current_textbox == null:
			_current_textbox._prepare()
		
			if different_textbox_type:
				_current_textbox._open()
				yield(_current_textbox, "opened_textbox")
		
			_current_textbox._show()
			yield(_current_textbox, "showed_textbox")
		
		is_queue_active = !_current_textbox == null
	emit_signal("finished_textbox_queue")


# Just a base class for different types of textboxes.
class RPGH_Textbox:
	
	# The signals are used in the subclasses.
# warning-ignore:unused_signal
	signal opened_textbox
# warning-ignore:unused_signal
	signal showed_textbox
# warning-ignore:unused_signal
	signal closed_textbox
	
	enum Type {
		DEFAULT_TEXTBOX,
		SCREEN_TEXT
	}
	
	var text = ""
	var type
	
	
	func _prepare():
		pass
	
	
	func _open():
		pass
	
	
	func _show():
		pass
		
	
	func _close():
		pass

class RPGH_DefaultTextbox:
	extends RPGH_Textbox
	
	var left_artwork = null
	var right_artwork = null
	
	
	func _init():
		type = Type.DEFAULT_TEXTBOX
	
	
	func _prepare():
		RPGH.Dialog.Textbox.text = text
		
		if !left_artwork == null:
			if !RPGH.Dialog._is_left_bust_visible:
				RPGH.Dialog.LeftBust.texture = left_artwork
				RPGH.Dialog.LeftBustAnimationPlayer.play("SpawnBust")
				RPGH.Dialog._is_left_bust_visible = true
			else:
				RPGH.Dialog.LeftBust.texture = left_artwork
		if !right_artwork == null:
			if !RPGH.Dialog._is_right_bust_visible:
				RPGH.Dialog.RightBust.texture = right_artwork
				RPGH.Dialog.RightBustAnimationPlayer.play("SpawnBust")
				RPGH.Dialog._is_right_bust_visible = true
			else:
				RPGH.Dialog.RightBust.texture = right_artwork
	
	
	func _open():
		RPGH.Player._player_movement_disabled = true
		RPGH.Player._player_interact_disabled = true
		RPGH.Dialog.DialogAnimationPlayer.play("SpawnTextbox")
		yield(RPGH.Dialog.DialogAnimationPlayer, "animation_finished")
		emit_signal("opened_textbox")
	
	
	func _show():
		RPGH.Dialog.Textbox.start_show_characters_animation()
		yield(RPGH.Dialog.Textbox, "accepted")
		emit_signal("showed_textbox")
	
	
	func _close():
		if RPGH.Dialog._is_left_bust_visible:
			RPGH.Dialog.LeftBustAnimationPlayer.play("DespawnBust")
			RPGH.Dialog._is_left_bust_visible = false
		if RPGH.Dialog._is_right_bust_visible:
			RPGH.Dialog.RightBustAnimationPlayer.play("DespawnBust")
			RPGH.Dialog._is_right_bust_visible = false
		RPGH.Dialog.Textbox.visible_characters = 0
		RPGH.Dialog.DialogAnimationPlayer.play("DespawnTextbox")
		yield(RPGH.Dialog.DialogAnimationPlayer, "animation_finished")
		emit_signal("closed_textbox")


class RPGH_ScreenText:
	extends RPGH_Textbox
	
	
	func _init():
		type = Type.SCREEN_TEXT
	
	
	func _prepare():
		RPGH.Dialog.Textbox.text = text
	
	
	func _open():
		RPGH.Player._player_movement_disabled = true
		RPGH.Player._player_interact_disabled = true
		RPGH.Dialog.DialogAnimationPlayer.play("SpawnScreenText")
		yield(RPGH.Dialog.DialogAnimationPlayer, "animation_finished")
		emit_signal("opened_textbox")
	
	
	func _show():
		RPGH.Dialog.Textbox.start_show_characters_animation()
		yield(RPGH.Dialog.Textbox, "accepted")
		emit_signal("showed_textbox")
	
	
	func _close():
		RPGH.Dialog.Textbox.visible_characters = 0
		RPGH.Dialog.DialogAnimationPlayer.play("DespawnScreenText")
		yield(RPGH.Dialog.DialogAnimationPlayer, "animation_finished")
		emit_signal("closed_textbox")
