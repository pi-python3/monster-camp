extends "Hero_State.gd"

const MOVE_SHADER = "res://Shaders/Move.tres";

onready var pos = owner.position;
var previous_motion = Vector2.ZERO;
export(float) var AVOID_RADIUS = 100;


func enter():
	owner.get_node("Sprite/Animation").play("Move");
	owner.get_node("Move_Particles").emitting = true;
	owner.get_node("Sprite_Handler").change_shader(MOVE_SHADER);
	
	owner.get_node("Emotion_Sign").show_emotion("scared");


func exit():
	owner.get_node("Sprite/Animation").stop();
	owner.get_node("Move_Particles").emitting = false;
	owner.get_node("Sprite").rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	$Line2D.clear_points();


func update():
	if Monster_Vars.monsters.size() < 1:
		emit_signal("finished", "idle");
		return;
	
	set_motion();
	move();
	animate();


func move():
	pos = owner.position;

	if $Switch_Direction_Timer.is_stopped():
		if sign(previous_motion.x) != sign(owner.motion.x):
			$Switch_Direction_Timer.start();
			previous_motion = owner.motion;
		else:
			owner.move_and_slide(owner.motion);
			previous_motion = owner.motion;
	else:
		owner.move_and_slide(previous_motion);


func set_motion():
	var space_state = get_world_2d().direct_space_state;
	$Line2D.clear_points();
	owner.motion = avoid_in_all_directions(owner.position, AVOID_RADIUS, owner.move_speed, AVOID_RADIUS, space_state, collision_mask, $Line2D);
#	var monster_positions = [];
#	for m in Monster_Vars.monsters:
#		monster_positions.append(m.position);
#
#	monster_positions.append(Vector2(pos.x, 0));
#	monster_positions.append(Vector2(pos.x, 600));
#	monster_positions.append(Vector2(0, pos.y));
#	monster_positions.append(Vector2(600, pos.y));
#
#	owner.motion = avoid_targets(pos, monster_positions, AVOID_RADIUS, owner.move_speed);


func animate():
	owner.get_node("Sprite").set_flip(previous_motion.x < 0);
	owner.get_node("Move_Particles").process_material.direction = Vector3(-owner.motion.x, -owner.motion.y, 0);
