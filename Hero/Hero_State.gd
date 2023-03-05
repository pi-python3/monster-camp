extends "Navigation_AI.gd"

signal finished(next_state_name);

# Initialize the state. E.g. change the animation
func enter():
	return;

# Clean up the state. Reinitialize values like a timer
func exit():
	return;

func handle_input(event):
	return;

#get input in update function
func input_update():
	return;

func update():
	input_update();
	return;

func _on_animation_finished(anim_name):
	return;


func find_closest_target(list=Game_Vars.target_points, ignore_priority:=false):
	if list.size() < 1: return null;
	elif list.size() == 1: return list[0];
	
	var min_score = 999999;
	var close_target;
	var see_priority: float = 0 if ignore_priority else 1;

	for target in list:
		if weakref(target).get_ref() == null: continue;
		
		var priority_num: float = see_priority * 100.0 / float(target.priority);

		var score = owner.global_position.distance_to(target.global_position) * priority_num;
		if score < min_score: 
			min_score = score;
			close_target = target;

	return close_target;


func get_closest_target_in_anchor(anchor: Node):
	var targets = [];
	
	for child in anchor.get_children():
		if child.is_in_group("Target_Point"):
			targets.append(child);
	
	return find_closest_target(targets);
