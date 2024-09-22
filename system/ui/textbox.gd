extends RichTextLabel

signal accepted

const CHARACTERS_PER_SECOND = 25.0
const ACCELERATED_CHARACTERS_PER_SECOND = 260.0

var _in_show_characters_animation = false
var _add_character_timer = 0.0
var _seconds_per_character


func _process(delta):
	if _in_show_characters_animation:
		_add_character_timer += delta
		var characters_to_add = _add_character_timer / _seconds_per_character
		var floored_characters_to_add = floor(characters_to_add)
		_add_character_timer -= floored_characters_to_add * _seconds_per_character
		visible_characters += floored_characters_to_add
		
		var total_character_count = get_total_character_count()
		if visible_characters >= total_character_count:
			visible_characters = -1
			_in_show_characters_animation = false


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if _in_show_characters_animation: # accelerate show characters animation.
			_seconds_per_character = 1.0 / ACCELERATED_CHARACTERS_PER_SECOND
		else:
			emit_signal("accepted")


func start_show_characters_animation():
	_in_show_characters_animation = true
	_seconds_per_character = 1.0 / CHARACTERS_PER_SECOND
	_add_character_timer = 0.0
	visible_characters = 0
