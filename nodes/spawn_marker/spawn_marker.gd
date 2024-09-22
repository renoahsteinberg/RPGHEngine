tool
extends Node2D

var _TEXTURE


func _init():
	if Engine.editor_hint:
		_TEXTURE = load("res://addons/rpgh_engine/nodes/spawn_marker/spawn_marker.png")


func _ready():
	if !Engine.editor_hint:
		RPGH.Player.spawn(position)


func _draw():
	if Engine.editor_hint:
		draw_texture(_TEXTURE, Vector2(0.0, -12.0))
