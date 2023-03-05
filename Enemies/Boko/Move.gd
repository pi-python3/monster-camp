extends "../Motion.gd"

export(float) var ACCELERATION = 1.7;
export(float) var MAX_MOVESPEED = 350;

export(Animation) var MOVE_ANIMATION = preload("res://Enemies/Move.tres");
export(bool) var FLIP_ON_INPUT = true;

var input_direction = Vector2.ZERO;
var final_input_direction = Vector2.ZERO;

onready var sprite = owner.get_node("Sprite");


func enter():
	sprite.frame = 0;
	owner.speed = MAX_MOVESPEED * 0.1;
	
	if MOVE_ANIMATION != null:
		sprite.get_node("Animation").add_animation("move_anim", MOVE_ANIMATION);
		sprite.get_node("Animation").play("move_anim");
	
	owner.get_node("Sprite_Handler").change_shader(Preloads.MOVE_SHADER_PATH);
	
	owner.get_node("Effects").emit_move_particles(true);


func exit():
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	owner.get_node("Effects").emit_move_particles(false);


func update(delta): 
	if input_update(): return;
	move();
	animate();


func input_update():
	input_direction = get_input_direction();
	if input_direction == Vector2.ZERO: 
		emit_signal("finished", "idle");
		return true;
	
	elif get_attack_input():
		final_input_direction = input_direction;
		emit_signal("finished", "attack");
		return true;
	
	return false;


func move():
	var motion = owner.motion;
	var speed = owner.speed;
	
	motion = input_direction * speed;
	
	#adjust speed for diagonal movement
	if input_direction.x != 0 && input_direction.y != 0: 
		motion /= sqrt(2);
	
	#accelerate
	speed = clamp(speed * ACCELERATION, MAX_MOVESPEED * 0.1, MAX_MOVESPEED);
	
	owner.motion = motion;
	owner.speed = speed;
	owner.move_and_slide(owner.motion); #move


func animate():
	if FLIP_ON_INPUT:
		if input_direction.x == -1: sprite.set_flip(true);
		elif input_direction.x == 1: sprite.set_flip(false);
	
	owner.get_node("Effects").set_move_particles_dir( Vector3(-input_direction.x, -input_direction.y, 0) );
