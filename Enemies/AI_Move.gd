extends "res://Hero/Navigation_AI.gd"

signal finished(next_state);

export(int) var AVOID_RADIUS = 50;

var move_speed;
onready var sprite = owner.get_node("Sprite");
var can_run = false;
var following = false;
var previous_following = false;
var weak_controlled_monster;


func _ready():
	if "MAX_SLOW_MOVESPEED" in get_parent().get_node("Move"):
		move_speed = get_parent().get_node("Move").MAX_SLOW_MOVESPEED;
	else:
		move_speed = get_parent().get_node("Move").MAX_MOVESPEED;


func enter():
	owner = get_parent().owner;
	sprite.frame = 0;
	sprite.get_node("Animation").play("Move");
	owner.get_node("Sprite_Handler").change_shader(Preloads.MOVE_SHADER_PATH);
	$Run_Cooldown.start();

func exit():
	owner = get_parent().owner;
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();


func update():
	owner = get_parent().owner;
	
	if can_run:
		owner.motion = steer(Vector2(0,0), avoid_hero(15), 0);
		print(owner.motion)

	if owner.controlled || owner.motion == Vector2.ZERO:
		if owner.controlled: can_run = false;
		emit_signal("finished", "idle");
		return;
	
	move();
	animate();


func avoid_hero(buffer: float = 0):
	owner = get_parent().owner;
	
	var avoid_positions = [Hero_Vars.position];
	var pos = owner.position;
	avoid_positions.append(Vector2(pos.x, 0));
	avoid_positions.append(Vector2(pos.x, 600));
	avoid_positions.append(Vector2(0, pos.y));
	avoid_positions.append(Vector2(600, pos.y));
	var motion = avoid_targets(owner.global_position, avoid_positions, AVOID_RADIUS + buffer, move_speed);
#	motion = motion.normalized() * move_speed;
	return motion;


func close_to_hero():
	owner = get_parent().owner;
	
	if following: return Vector2.ZERO;
	
	elif owner.position.distance_to(Hero_Vars.position) <= AVOID_RADIUS:
		return Vector2.RIGHT;
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


func _on_Run_Cooldown_timeout():
	can_run = false;
