extends Node

export(String, FILE, "*.tscn") var initial_map

func _ready():
	RPGH.MapManager.map = initial_map
