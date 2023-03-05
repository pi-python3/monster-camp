extends "res://Scripts/State.gd"

func get_input_direction() -> Vector2:
	var input_dir = Vector2();
	if owner.controlled:
		input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
		input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));

	return input_dir;

func get_global_input_direction() -> Vector2:
	var input_dir = Vector2();
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));

	return input_dir;


func get_attack_input(disregard_can_attack=false) -> bool:
	if disregard_can_attack:
		if !owner.controlled: return false;
	else:
		if !owner.can_attack or !owner.controlled: return false;
	
	var attack = Input.is_action_just_pressed("attack");
	return attack;
