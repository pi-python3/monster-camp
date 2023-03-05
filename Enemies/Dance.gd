extends "Motion.gd"

var ACCELERATION;
var MAX_MOVESPEED;

var sprite;

var input_direction := Vector2.ZERO;


func setup_variables():
	ACCELERATION = get_parent().get_node("Move").ACCELERATION;
	MAX_MOVESPEED = get_parent().get_node("Move").MAX_MOVESPEED;
	sprite = owner.get_node("Sprite");


func enter():
	owner = get_parent().owner;
	setup_variables();
	
	sprite.frame = 0;
	owner.speed = MAX_MOVESPEED * 0.1;

	sprite.get_node("Animation").play("Dance");
	
	owner.get_node("Sprite_Handler").change_shader(Preloads.MOVE_SHADER_PATH);
	owner.get_node("Effects").emit_move_particles(true);


func exit():
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	sprite.position = Vector2(0,0);
	owner.get_node("Sprite_Handler").clear_shader();
	owner.get_node("Effects").emit_move_particles(false);


func update(delta): 
	input_update()
	move();
	animate();


func input_update():
	input_direction = get_input_direction();


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
	if input_direction.x == -1: sprite.set_flip(true);
	elif input_direction.x == 1: sprite.set_flip(false);
	
	owner.get_node("Effects").set_move_particles_dir( Vector3(-input_direction.x, -input_direction.y, 0) );


func play_sfx(sfx: String):
	if sfx != null:
		Sound_Manager.play_sound_pitch_range(sfx + ".wav", 0.9, 1.05);
