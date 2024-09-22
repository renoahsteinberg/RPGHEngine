extends Node

enum ViewDirection {
	UP = 0,
	UP_RIGHT = 1,
	RIGHT = 2,
	DOWN_RIGHT = 3,
	DOWN = 4,
	DOWN_LEFT = 5,
	LEFT = 6,
	UP_LEFT = 7
}

signal texture_position_updated(new_position)
signal tile_reached()
signal frame_pushed(frame_coord)

const SPEED = 100.0
const STEP = 8.0
const FRAMES_PER_SECOND = 8.0

var view_direction = ViewDirection.DOWN
var body_direction = Vector2.DOWN

var speed_multiplier = 1.0

# For movement.
var _previous_position
var _target_position
var _in_walk_animation = false
var _walk_interpolation_ratio = 0.0

# For sheet animation.
var _in_idle_frame = true
var _frame_timer = 0.0
var _previous_frame_timer = 0.0
var _next_initial_frame_timer = 0.0
var _frame_coords
var _previous_frame_coords


func _process(delta):
	_handle_walk_animation(delta)
	_handle_sprite_sheet_animation(delta)


func start_walk_animation(destination: Vector2):
	_previous_position = _target_position
	_target_position = destination
	_in_walk_animation = true
	_in_idle_frame = false


func stop_walk_animation():
	_walk_interpolation_ratio = 0.0
	_in_walk_animation = false
	emit_signal("texture_position_updated", _target_position)


func set_position(new_position):
	_previous_position = new_position
	_target_position = new_position
	emit_signal("texture_position_updated", _target_position)


func is_in_walk_animation():
	return _in_walk_animation


func _handle_walk_animation(delta):
	if _in_walk_animation:
		_walk_interpolation_ratio += SPEED * speed_multiplier / STEP * delta
		if _walk_interpolation_ratio >= 1.0:
			_walk_interpolation_ratio -= 1.0
			emit_signal("tile_reached")
		else:
			var next_position = _previous_position.linear_interpolate(
				_target_position, _walk_interpolation_ratio)
			emit_signal("texture_position_updated", next_position)


func _handle_sprite_sheet_animation(delta):
	_frame_coords = Vector2.ZERO
	
	if _in_walk_animation:
		if _in_idle_frame:
			_in_idle_frame = false
			_frame_timer = _next_initial_frame_timer
		_frame_coords.x = floor(_get_wraped_frame_timer(delta) + 1.0)
	else:
		if _in_idle_frame:
			_frame_coords.x = 0.0
		else:
			_handle_after_walk_animation(delta)
	
	_frame_coords.y = view_direction
	
	if _frame_coords != _previous_frame_coords:
		emit_signal("frame_pushed", _frame_coords)


# The humanoid is supposed to finish its walking animation,
# even if it already reached a whole tile.
func _handle_after_walk_animation(delta):
	var wraped_previous_frame_timer = wrapf(_previous_frame_timer, 0.0, 4.0)
	var wraped_frame_timer = _get_wraped_frame_timer(delta)
	
	_next_initial_frame_timer = floor(wraped_frame_timer * 0.5) * 2.0
	
	var walk_animation_frame = floor(wraped_frame_timer) + 1.0
	
	var wraped_2 = wrapf(wraped_frame_timer, 1.0, 3.0) - 1.0
	var previous_wraped_2 = wrapf(wraped_previous_frame_timer, 1.0, 3.0) - 1.0
	
	if previous_wraped_2 > wraped_2:
		_in_idle_frame = true
		_frame_coords.x = 0.0
	else:
		_frame_coords.x = walk_animation_frame


func _get_wraped_frame_timer(delta):
	_previous_frame_timer = _frame_timer
	_frame_timer += delta * FRAMES_PER_SECOND
	return wrapf(_frame_timer, 0.0, 4.0)
