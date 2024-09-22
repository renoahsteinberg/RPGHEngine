class_name RPGH_Trigger, "res://addons/rpgh_engine/nodes/trigger/icon_trigger.svg"
extends Node

enum TriggerType {
	ON_INTERACT,
	ON_TOUCH,
}

export(NodePath) var event = @".."
# Both not functioning yet!
export(TriggerType) var trigger_type = TriggerType.ON_INTERACT
export(bool) var is_passable = false


onready var passable_trigger = preload("res://addons/rpgh_engine/nodes/trigger/passable_trigger.tscn")
onready var solid_trigger = preload("res://addons/rpgh_engine/nodes/trigger/solid_trigger.tscn")


func _ready():
	var collision_object: CollisionObject2D
	
	if is_passable:
		collision_object = passable_trigger.instance()
	else:
		collision_object = solid_trigger.instance()
		collision_object.set_collision_layer_bit(1, true)
	
	collision_object.name = name
	collision_object.event = get_node(event)
	
	call_deferred("replace_by", collision_object, true)
