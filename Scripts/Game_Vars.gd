extends Node

var target_points = [];


func _ready():
	process_priority = 2;
	Level_Handler.connect("new_level", self, "_new_level");
	Level_Handler.connect("changing_level", self, "_changing_level");


func _new_level(_level):
	pass;
#	level_reset();


func _changing_level():
	target_points.clear();


func level_reset():
#	yield(get_tree().create_timer(0.05),"timeout");

	target_points = [];
#	var environment_node = get_node_or_null("/root/Game/Environment/Monsters");
#
#	if environment_node == null: return;
	

func _on_target_point_added(target_point: TargetPoint):
	if not target_point in target_points:
		target_points.append(target_point);


func _on_target_point_removed(target_point: TargetPoint):
	if target_point in target_points:
		target_points.erase(target_point);
