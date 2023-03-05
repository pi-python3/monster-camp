extends "res://Hero/Navigation_AI.gd"

signal finished(next_state);

var SEEK_RADIUS := 250;
var CAN_ATTACK_WHILE_FOLLOWING := true;
var FOLLOW_SOUND_NAME := "Keesee_Screech.wav";

var move_speed;
onready var sprite;
#var can_run = false;
var following = false;
var previous_following = false;
var weak_controlled_monster;

func _ready():
	if "MAX_SLOW_MOVESPEED" in get_parent().get_node("Move"):
		move_speed = get_parent().get_node("Move").MAX_SLOW_MOVESPEED;
	else:
		move_speed = get_parent().get_node("Move").MAX_MOVESPEED;


func enter():
	sprite = get_parent().owner.get_node("Sprite");
	sprite.frame = 0;
	sprite.get_node("Animation").play("Move");
	get_parent().owner.get_node("Sprite_Handler").change_shader(Preloads.MOVE_SHADER_PATH);


func exit():
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	if !close_to_monster():
		following = false;
		previous_following = false;


func update():
	owner = get_parent().owner;
	
	owner.motion = seek_monster();
	
	if get_attack_input() && following && CAN_ATTACK_WHILE_FOLLOWING:
		get_parent().get_node("Move").final_input_direction = owner.motion.normalized();
		emit_signal("finished", "attack");
	
	if previous_following != following:
		previous_following = following;
		if following:
			owner.get_node("Follow_Signal").signal_out(Monster_Vars.controlled_monster.position);
			Sound_Manager.play_sound(FOLLOW_SOUND_NAME);


	if owner.controlled || owner.motion == Vector2.ZERO:
		emit_signal("finished", "idle");
		return;
	
	move();
	animate();


func close_to_monster():
	weak_controlled_monster = weakref(Monster_Vars.controlled_monster);
	if weak_controlled_monster.get_ref() == null: return Vector2.ZERO;

	if get_parent().owner.position.distance_to(Monster_Vars.controlled_monster.position) <= SEEK_RADIUS:
		return true;
	return false;


func seek_monster():
	if weakref(Monster_Vars.controlled_monster).get_ref() == null: return Vector2.ZERO;
	owner = get_parent().owner;
	var distance = owner.position.distance_to(Monster_Vars.controlled_monster.position);
	
	var adder = 0; #buffer zone between seek radius and blank
	if following: adder = SEEK_RADIUS * 0.1;
	
	if distance <= SEEK_RADIUS + adder:
		var seek_motion = seek(owner.position, owner.position + Monster_Vars.controlled_monster.motion, move_speed, 50);
		var seek_position = seek(owner.position, Monster_Vars.controlled_monster.position, move_speed, 50);
		var motion := Vector2.ZERO;
		if "current_movespeed" in Monster_Vars.controlled_monster.get_node("States/Move"):
			motion = seek_motion.normalized() * Monster_Vars.controlled_monster.get_node("States/Move").current_movespeed;
		else:
			motion = seek_motion.normalized() * Monster_Vars.controlled_monster.get_node("States/Move").MAX_MOVESPEED;
		motion = ((motion*9) + seek_position) / 10;
		following = true;
		return motion;
#		else:
#			return (seek_motion + seek_position) / 2;
	
	following = false;
	return Vector2.ZERO;


func move():
	owner.move_and_slide(owner.motion);


var deltatime = 0;
func _process(delta):
	deltatime += delta;


func animate():
	if deltatime >= 1.0/3.0:
		sprite.set_flip(owner.motion.x < 0);
		deltatime = 0;
#	owner.get_node("Move_Particles").process_material.direction = Vector3(-owner.motion.x, -owner.motion.y, 0);
