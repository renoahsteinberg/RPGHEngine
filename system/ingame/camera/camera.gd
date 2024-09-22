extends Camera2D

var _previous_observee_position: Vector2

var _previous_camera_setup := CameraSetup.new()
var _target_camera_setup := CameraSetup.new() # This one is used if only one ist set.
var _fade_over_start_timestamp = 0.0
var _fade_over_duration = 0.0 
var _fade_over_smooth = false

onready var IngameDisplay = get_node("../../../Display")


func _process(_delta):
#	if not _previous_observee_position == RPGH.Camera._get_definite_position():
#		_previous_observee_position = RPGH.Camera._get_definite_position()
#		_update_camera_position()
#	elif RPGH.Camera._is_zoom_invalid:
#		_update_camera_position()
#	RPGH.Camera._is_zoom_invalid = false
	_update_camera_position()


func set_camera_setup(camera_setup):
	_target_camera_setup = camera_setup
	_fade_over_duration = 0.0


func fade_over_camera_setup(camera_setup, duration, smooth = false):
	_previous_camera_setup = _target_camera_setup
	_target_camera_setup = camera_setup
	_fade_over_start_timestamp = OS.get_ticks_msec() * 0.001
	_fade_over_duration = duration
	_fade_over_smooth = smooth


func _get_definite_position():
	var previous_position = _previous_camera_setup.position
	var target_position = _target_camera_setup.position
	var ratio = _get_ratio_over_time()
	return previous_position.linear_interpolate(target_position, ratio)


func _get_definite_zoom():
	var previous_zoom = _previous_camera_setup.zoom
	var target_zoom = _target_camera_setup.zoom
	var ratio = _get_ratio_over_time()
	return lerp(previous_zoom, target_zoom, ratio)


func _get_ratio_over_time():
	var current_timestamp = OS.get_ticks_msec() * 0.001
	var passed_time = current_timestamp - _fade_over_start_timestamp
	var ratio
	if _fade_over_duration > 0.0:
		ratio = clamp(passed_time / _fade_over_duration, 0.0, 1.0)
	else:
		ratio = 1.0
	if _fade_over_smooth:
		if ratio <= 0.5:
			ratio = pow(ratio * 2.0, 3.0) * 0.5
		else:
			ratio = 1.0 - ratio
			ratio = pow(ratio * 2.0, 3.0) * 0.5
			ratio = 1.0 - ratio
	return ratio


func _update_camera_position():
	var definite_position = _get_definite_position()
	var definite_zoom = _get_definite_zoom()
	
	var whole_definite_position = Vector2(floor(definite_position.x), floor(definite_position.y))
	var decimal_part = definite_position - whole_definite_position
	var zoomed_decimal_part = decimal_part * -1.6 * definite_zoom
	position = whole_definite_position
	IngameDisplay.get_material().set_shader_param("offset", zoomed_decimal_part)
	IngameDisplay.get_material().set_shader_param("zoom", definite_zoom)
	force_update_scroll()


class CameraSetup:
	var observee: Node2D = null setget ,_get_observee
	var pixel_perfect = false setget ,_get_pixel_perfect # Forced if observee is player.
	var position = Vector2() setget ,_get_position
	var zoom := 1.0 setget _set_zoom, _get_zoom
	var limit_left := -INF
	var limit_right := INF
	var limit_top := -INF
	var limit_bottom := INF
	
	var _previous_observee_position
	var _is_zoom_invalid = false
	var _cached_position = Vector2()
	var _cached_zoom
	
	
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
	func _calculate_and_cache_position_and_zoom(position, zoom):
		var zoomed_screen_size = RPGH.DEFAULT_SCREEN_SIZE * zoom
		var half_zoomed_screen_size = zoomed_screen_size * 0.5
		
		var horizontal_border_alignment = _align_and_squish_borders(
			position.x, half_zoomed_screen_size.x, limit_left, limit_right
			)
		
		_cached_position.x = horizontal_border_alignment[0]
		var left_border = horizontal_border_alignment[1]
		var right_border = horizontal_border_alignment[2]
		var horizontal_size = right_border - left_border
		var horizontal_zoom = RPGH.DEFAULT_SCREEN_SIZE.x / horizontal_size
		
		var vertical_border_alignment = _align_and_squish_borders(
			position.y, half_zoomed_screen_size.y, limit_top, limit_bottom
			)
		
		_cached_position.y = vertical_border_alignment[0]
		var top_border = vertical_border_alignment[1]
		var bottom_border = vertical_border_alignment[2]
		var vertical_size = bottom_border - top_border
		var vertical_zoom = RPGH.DEFAULT_SCREEN_SIZE.y / vertical_size
		
		if _get_pixel_perfect():
			_cached_position = Vector2(floor(_cached_position.x), floor(_cached_position.y))
		_cached_zoom = min(horizontal_zoom, vertical_zoom)
	
	
	func _align_and_squish_borders(current_position, expansion, limit_negative, limit_positive):
		#var current_position = position
		var left_border = current_position - expansion
		var right_border = current_position + expansion
		
		if limit_negative > left_border:
			current_position += limit_negative - left_border
			left_border = limit_negative
			right_border = current_position + expansion
			if limit_positive < right_border:
				right_border = limit_positive
				current_position = (left_border + right_border) * 0.5
		elif limit_positive < right_border:
			current_position += limit_positive - right_border
			right_border = limit_positive
			left_border = current_position - expansion
			if limit_negative > left_border:
				left_border = limit_negative
				current_position = (left_border + right_border) * 0.5
		
		return [current_position, left_border, right_border]
	
	
	func _get_observee():
		if not is_instance_valid(observee):
			observee = null
		if observee == null:
			if RPGH.Player._player_exists:
				return RPGH.Player.CameraFocus
			else:
				return RPGH.Player.CameraFocus # CHANGE THIS PLEASE. #later# CHANGE TO WHAT?!
		else:
			return observee
	
	
	func _get_pixel_perfect():
		if observee == null:
			return true
		else:
			return pixel_perfect
	
	
	func _get_position():
		var observee_position = _get_observee().global_position
		
		var is_position_invalid = not observee_position == _previous_observee_position
		
		if is_position_invalid or _is_zoom_invalid:
			_previous_observee_position = observee_position
			_is_zoom_invalid = false
			_calculate_and_cache_position_and_zoom(observee_position, zoom)
		
		return _cached_position
	
	
	func _set_zoom(value):
		zoom = value
		_is_zoom_invalid = true
		RPGH.Camera.IngameDisplay.get_material().set_shader_param("zoom", zoom)
	
	
	func _get_zoom():
		var observee_position = _get_observee().global_position
		
		var is_position_invalid = not observee_position == _previous_observee_position
		
		if is_position_invalid or _is_zoom_invalid:
			_previous_observee_position = observee_position
			_is_zoom_invalid = false
			_calculate_and_cache_position_and_zoom(observee_position, zoom)
		
		return _cached_zoom
