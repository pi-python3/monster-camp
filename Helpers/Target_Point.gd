extends Position2D

class_name TargetPoint, "res://Meta/Target_Point_Icon.png"

signal target_point_created(target_point);
signal target_point_removed(target_point);

export(NodePath) var anchor_object_levels = null;
export(bool) var active = true setget set_active;
export(int) var priority = 5;

var anchor: Node;


func _ready():
	if anchor_object_levels == null:
		anchor = owner;
	else:
		anchor = get_parent_levels_up(anchor_object_levels);
	
	if !owner.is_in_group("Has_Target_Point"):
		owner.add_to_group("Has_Target_Point");
	
	if owner.has_signal("remove_target_points"):
		owner.connect("remove_target_points", self, "_on_remove_point");
	
	connect("target_point_created", Game_Vars, "_on_target_point_added");
	connect("target_point_removed", Game_Vars, "_on_target_point_removed");
	
	set_active(active);
#	emit_signal("target_point_created", self);


func _on_remove_point():
	if owner.is_in_group("Has_Target_Point"):
		owner.remove_from_group("Has_Target_Point");
	
	emit_signal("target_point_removed", self);
	queue_free();


func get_parent_levels_up(levels) -> Node:
	var parent: Node = self;
	var l = levels;
	
	for i in range(l):
		parent = parent.get_parent();
	
	return parent;


func set_active(value: bool):
	active = value;
	
	if value == true:
		$Sprite.frame = 0;
		$Sprite.modulate.a = 1.0;
		if !is_in_group("Target_Point"): add_to_group("Target_Point");
		emit_signal("target_point_created", self);
	
	else:
		$Sprite.frame = 1;
		$Sprite.modulate.a = 1.0;
		if is_in_group("Target_Point"): remove_from_group("Target_Point");
		emit_signal("target_point_removed", self);
