extends YSort

var map = null setget _set_map

func _set_map(value):
	if !value == null:
		if !map == null:
			map.queue_free()
			yield(map, "tree_exited")
		var instanced_map = _map_to_node(value)
		if instanced_map != null:
			add_child(instanced_map)
			map = instanced_map
		print("Map set!")
	else:
		if !map == null:
			map.queue_free()


# Pass either a String, a PackedScene or a Node
# directly to certainly get a Node
func _map_to_node(node_information) -> Node:
	if node_information is String:
		return load(node_information).instance()
	elif node_information is PackedScene:
		return node_information.instance()
	elif node_information is Node:
		return node_information
	else:
		push_error("No supported format was passed for the map!")
		return null
