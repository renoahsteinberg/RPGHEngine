tool
class_name RPGH_Map, "res://addons/rpgh_engine/nodes/map/icon_map.svg"
extends YSort

export(Texture) var top_layer: Texture setget _set_top_layer
export(Texture) var bottom_layer: Texture setget _set_bottom_layer


func _init():
	if !Engine.editor_hint:
		RPGH.get_node("DataManager").current_map = self


func _ready():
	if get_parent() == get_tree().get_root():
		print("is correct")
		get_parent().call_deferred("remove_child", self)
		RPGH.MapManager.call_deferred("add_child", self)
	
	if !Engine.editor_hint:
		var top_layer_sprite = Sprite.new()
		top_layer_sprite.name = "\\TopLayer"
		top_layer_sprite.texture = top_layer
		top_layer_sprite.centered = false
		top_layer_sprite.z_index = 1
		add_child(top_layer_sprite)
		
		var bottom_layer_sprite = Sprite.new()
		bottom_layer_sprite.name = "\\BottomLayer"
		bottom_layer_sprite.texture = bottom_layer
		bottom_layer_sprite.centered = false
		bottom_layer_sprite.z_index = -1
		add_child(bottom_layer_sprite)


func _draw():
	if Engine.editor_hint:
		draw_texture(bottom_layer, Vector2())
		draw_texture(top_layer, Vector2())


func _set_top_layer(new_top_layer):
	top_layer = new_top_layer
	update()


func _set_bottom_layer(new_bottom_layer):
	bottom_layer = new_bottom_layer
	update()


# Just a fast wrapper for "storable.gd".
class RPGH_Storable:
	extends "res://addons/rpgh_engine/system/data_management/storable.gd"
	func _init(key: String, value = null, map = null, event = null).(key, value, map, event): pass
func Storable(key: String, value = null) -> RPGH_Storable:
	return RPGH_Storable.new(key, value, self)
