extends Node

const DEFAULT_SCREEN_SIZE = Vector2(640, 360)

onready var DataManager = get_node("DataManager")
onready var CommandSystem = get_node("DataManager/CommandSystem")
onready var MapManager = get_node("Ingame/Viewport/MapManager")
onready var Player = get_node("Ingame/Viewport/MapManager/Player")
onready var Camera = get_node("Ingame/Viewport/MapManager/Camera")
onready var Dialog = get_node("UI/Dialog")
