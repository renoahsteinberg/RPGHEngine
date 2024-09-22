extends Popup

export var pause = false

# Doesn't prevent zooming at the start of the Game

func _process(delta):
	if Input.is_action_just_pressed("game_pause"):
		_pause_manager()


func _pause_manager():
	if !pause:
		get_tree().paused = true
		show()
		pause = true
	else:
		hide()
		get_tree().paused = false
		pause = false
