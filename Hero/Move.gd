extends "Hero_State.gd"

const MOVE_SHADER = "res://Shaders/Move.tres";

onready var pos = owner.global_position;
var previous_motion = Vector2.ZERO;
var path;


func enter():
	owner.get_node("Sprite/Animation").play("Move");
	owner.get_node("Sprite_Handler").change_shader(MOVE_SHADER);
	owner.get_node("Move_Particles").emitting = true;


func exit():
	owner.get_node("Sprite/Animation").stop();
	owner.get_node("Sprite").rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	owner.get_node("Move_Particles").emitting = false;


func update():
	if Game_Vars.target_points.size() < 1:
		emit_signal("finished", "idle");
		return;
	
	move();
	animate();
	AI_action();
	check_attack();

func move():
	pos = owner.global_position;

	if $Switch_Direction_Timer.is_stopped():
		if sign(previous_motion.x) != sign(owner.motion.x):
			$Switch_Direction_Timer.start();
			previous_motion = owner.motion;
		else:
			owner.move_and_slide(owner.motion);
			previous_motion = owner.motion;
	else:
		owner.move_and_slide(previous_motion);
#func move():
#	pos = owner.position;
#	if sign(previous_motion.x) != sign(previous_motion.x):
#		$Switch_Direction_Timer.start();
#
#	if $Switch_Direction_Timer.is_stopped():
#		owner.move_and_slide(owner.motion);
#	previous_motion = owner.motion;


func AI_action():
	if Hero_Vars.revenge_target != null: revenge_attack();
	elif Hero_Vars.stamina >= 1: attack_closest_target();


func check_attack():
	var closest_target = find_closest_target();
	if Hero_Vars.stamina <= 0 || closest_target == null: return;
	
	var distance_to_monster = pos.distance_to(closest_target.global_position);
	
	if Hero_Vars.stamina > 0 && get_parent().get_sword_in_range(closest_target):
		owner.motion = move_toward_point(pos, closest_target.global_position, owner.move_speed, owner.motion).normalized();
		animate(); #make sure hero is facing towards monster
		
		if closest_target.anchor == Hero_Vars.revenge_target: Hero_Vars.revenge_target = null;
		emit_signal("finished", "sword_attack");


func attack_closest_target():
#	if path != null:
#		if owner.global_position.distance_to(path[0]) < 5:
#			path.pop_front();
#		owner.motion = seek(owner.global_position, path[0], owner.move_speed);

	var closest_monster = find_closest_target();

	if get_parent().vars["can_navigate_to_monster"] && get_parent().vars["can_navigate_monsters"].size() > 0:
		owner.motion = move_toward_point(owner.global_position, find_closest_target(get_parent().vars["can_navigate_monsters"]).global_position, owner.move_speed, owner.motion);
	
	elif closest_monster != null:
		owner.motion = seek(owner.global_position, closest_monster.global_position, owner.move_speed);
	
	else:
		owner.motion = Vector2.ZERO;


func revenge_attack():
	if owner.get_node("Emotion_Sign").current_emotion != "angry":
		owner.get_node("Emotion_Sign").show_emotion("angry");
	
	var target = get_closest_target_in_anchor(Hero_Vars.revenge_target);
	if weakref(target).get_ref() != null:
		owner.motion = move_toward_point(owner.global_position, target.global_position, owner.move_speed, owner.motion);
	
	if $Revenge_Time.is_stopped(): $Revenge_Time.start();


func animate():
	owner.get_node("Sprite").set_flip(owner.motion.x < 0);
	owner.get_node("Move_Particles").process_material.direction = Vector3(-owner.motion.x, -owner.motion.y, 0);
	
	$Line2D.clear_points();
	$Line2D.add_point(owner.global_position);
	$Line2D.add_point(owner.global_position + owner.motion);
	
	$Line_2.clear_points();
	$Line_2.add_point(owner.global_position);
	if path:
		$Line_2.points = path;
	
#	$Line_2.add_point(path[1]);
#	if path != null: $Line2D.points = path;

func _on_Revenge_Time_timeout():
	Hero_Vars.revenge_target = null;
