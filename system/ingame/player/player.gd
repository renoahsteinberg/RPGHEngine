extends RPGH_Humanoid

enum Direction {
	UP = -1,
	LEFT = -1
	NONE = 0,
	RIGHT = 1,
	DOWN = 1
}

# Input variables.
var input_x_axis = Direction.NONE
var input_y_axis = Direction.NONE
var input_interact = false

var _player_exists = false
var _player_movement_disabled := false
var _player_interact_disabled := false
var _await_interaction = false

onready var InteractableAntenna = get_node("Body/InteractableAntenna")


func spawn(position: Vector2):
	Body.position = position
	AnimationHandler.set_position(Body.position)
	self.Texture.position = position
	self.Texture.visible = true
	_player_exists = true


func despawn():
	self.Texture.visible = false
	_player_exists = false


# Called when the node enters the scene tree for the first time.
func _ready():
	AnimationHandler.connect(
		"texture_position_updated", self, "_on_texture_position_updated")
	AnimationHandler.connect(
		"tile_reached", self, "_on_tile_reached")
	AnimationHandler.connect(
		"frame_pushed", self, "_on_frame_pushed")


func _physics_process(_delta):
	_check_input()
	
	if !AnimationHandler.is_in_walk_animation():
		if not _get_axis_input_vector() == Vector2.ZERO:
			InteractableAntenna.position = _get_axis_input_vector() * STEP * 2.0
		_move_player()
	
	if input_interact:
		if AnimationHandler.is_in_walk_animation():
			yield(AnimationHandler, "tile_reached")
		for i in InteractableAntenna.get_overlapping_areas():
			i.trigger()
		for i in InteractableAntenna.get_overlapping_bodies():
			i.trigger()
		_await_interaction = false


# Sets local axis input variables.
func _check_input():
	if not RPGH.Player._player_movement_disabled:
		# Handle input_x_axis
		if (Input.is_action_pressed("ingame_left") || Input.is_action_pressed("ingame_right")):
			if (Input.is_action_just_pressed("ingame_left")): input_x_axis = Direction.LEFT
			if (Input.is_action_just_pressed("ingame_right")): input_x_axis = Direction.RIGHT
		else: input_x_axis = Direction.NONE
		if (Input.is_action_just_released("ingame_left") && Input.is_action_pressed("ingame_right")): input_x_axis = Direction.RIGHT
		if (Input.is_action_just_released("ingame_right") && Input.is_action_pressed("ingame_left")): input_x_axis = Direction.LEFT
		# Handle input_y_axis
		if (Input.is_action_pressed("ingame_up") || Input.is_action_pressed("ingame_down")):
			if (Input.is_action_just_pressed("ingame_up")): input_y_axis = Direction.UP
			if (Input.is_action_just_pressed("ingame_down")): input_y_axis = Direction.DOWN
		else: input_y_axis = Direction.NONE
		if (Input.is_action_just_released("ingame_up") && Input.is_action_pressed("ingame_down")): input_y_axis = Direction.DOWN
		if (Input.is_action_just_released("ingame_down") && Input.is_action_pressed("ingame_up")): input_y_axis = Direction.UP
	else:
		input_x_axis = Direction.NONE
		input_y_axis = Direction.NONE
	if not RPGH.Player._player_interact_disabled:
		input_interact = Input.is_action_just_pressed("ingame_interact")
	else:
		input_interact = false


func _move_player() -> bool:
	var was_player_moved = not (input_x_axis == 0.0 and input_y_axis == 0.0)
	if was_player_moved:
		was_player_moved = move(_get_axis_input_vector())
	return was_player_moved


func _get_axis_input_vector() -> Vector2:
	return Vector2(input_x_axis, input_y_axis)


func _on_texture_position_updated(new_position):
	self.Texture.position = new_position


func _on_tile_reached():
	if !_move_player():
		AnimationHandler.stop_walk_animation()


func _on_frame_pushed(frame_coords):
	self.Texture.frame_coords = frame_coords
