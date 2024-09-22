class_name RPGH_Humanoid
extends YSort

const DIAGONAL_SPEED_MULTIPLIER = 0.8
const STEP = 8.0

onready var Texture = get_node("Texture")
onready var AnimationHandler = get_node("Texture/AnimationHandler")
onready var CameraFocus = get_node("Texture/CameraFocus")
onready var Body = get_node("Body")

onready var view_direction_map = {
	Vector2(0.0, -1.0) : AnimationHandler.ViewDirection.UP,
	Vector2(1.0, -1.0) : AnimationHandler.ViewDirection.UP_RIGHT,
	Vector2(1.0, 0.0) : AnimationHandler.ViewDirection.RIGHT,
	Vector2(1.0, 1.0) : AnimationHandler.ViewDirection.DOWN_RIGHT,
	Vector2(0.0, 1.0) : AnimationHandler.ViewDirection.DOWN,
	Vector2(-1.0, 1.0) : AnimationHandler.ViewDirection.DOWN_LEFT,
	Vector2(-1.0, 0.0) : AnimationHandler.ViewDirection.LEFT,
	Vector2(-1.0, -1.0) : AnimationHandler.ViewDirection.UP_LEFT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_if_on_tile()
	AnimationHandler.set_position(Body.position)


# Returns true if the humanoid is moved.
func move(direction: Vector2) -> bool:
	var direction_test_list = [ Vector2(direction.x, direction.y),
					# Default direction, rotated 45 degrees to the left.
						Vector2(
							clamp(direction.x + direction.y, -1.0, 1.0),
							clamp(direction.y - direction.x, -1.0, 1.0)),
					# Default direction, rotated 45 degrees to the right.
						Vector2(
							clamp(direction.x - direction.y, -1.0, 1.0),
							clamp(direction.y + direction.x, -1.0, 1.0)) ]
	
	# Already setting a few variables in case no test is successful.
	AnimationHandler.speed_multiplier = DIAGONAL_SPEED_MULTIPLIER
	if direction.x == 0 or direction.y == 0:
		AnimationHandler.speed_multiplier = 1.0
	var was_humanoid_moved = false
	
	for direction_test in direction_test_list:
		var step_to_destination = direction_test * STEP
		
		if !Body.test_move(Body.global_transform, step_to_destination):
			AnimationHandler.view_direction = view_direction_map[direction_test]
			AnimationHandler.speed_multiplier = DIAGONAL_SPEED_MULTIPLIER
			if direction_test.x == 0 or direction_test.y == 0:
				AnimationHandler.speed_multiplier = 1.0
			# Finally actually moving the body.
			Body.position += step_to_destination
			AnimationHandler.start_walk_animation(Body.position) 
			was_humanoid_moved = true
			break
	return was_humanoid_moved


# Checking if humanoid is positioned on a tile.
func _check_if_on_tile():
	var on_tile = true
	if not wrapf(position.x, 0.0, 8.0) == 0.0:
		position.x = round(position.x / 8.0) * 8.0
		on_tile = false
	if not wrapf(position.y, 0.0, 8.0) == 0.0:
		position.y = round(position.y / 8.0) * 8.0
		on_tile = false
	if not on_tile:
		push_warning("The humanoid was not exactly position on a tile! Please fix this.")
