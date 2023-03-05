extends "../Motion.gd"

export(float) var ACCELERATION = 1.7;
export(float) var MAX_MOVESPEED = 350;
onready var BASE_MAX_MOVESPEED = MAX_MOVESPEED;

var input_direction = Vector2.ZERO;
var final_input_direction = Vector2.ZERO;

onready var sprite = owner.get_node("Sprite");
onready var has_move_particles = owner.get_node_or_null("Move_Particles") != null;


func enter():
	MAX_MOVESPEED = BASE_MAX_MOVESPEED;
	
	owner.get_node("Collision").disabled = true;
	owner.get_node("Hitbox/Collision").disabled = true;
	
	sprite.frame = 0;
	owner.speed = MAX_MOVESPEED * 0.1;
	
	sprite.get_node("Animation").play("Move");
	
	owner.get_node("Sprite_Handler").change_shader(Preloads.MOVE_SHADER_PATH);
	
	if has_move_particles: owner.get_node("Move_Particles").emitting = true;
	sprite.hide();
	
	$Burrow_Timer.start();


func exit():
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	if has_move_particles:
		owner.get_node("Move_Particles").emitting = false;
	
	sprite.show();
	owner.get_node("Collision").disabled = false;
	owner.get_node("Hitbox/Collision").disabled = false;


func update(delta): 
	if input_update(): return;
	move();
	animate();


func input_update():
	input_direction = get_input_direction();
	
	if get_attack_input(true):
		surface();
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
	if input_direction.x == -1: sprite.set_flip(true);
	elif input_direction.x == 1: sprite.set_flip(false);
	
	if has_move_particles:
		owner.get_node("Move_Particles").process_material.direction = Vector3(-input_direction.x, -input_direction.y, 0);


func _on_Burrow_Timer_timeout():
	if owner.current_state == self:
		surface();


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Surface":
		emit_signal("finished", "idle");


func surface():
	if sprite.get_node("Animation").current_animation != "Surface":
		MAX_MOVESPEED = get_parent().get_node("Move").MAX_MOVESPEED;
		sprite.get_node("Animation").play("Surface");
		sprite.show();
		owner.get_node("Stamina_Bar").fill();
#		owner.get_node("Collision").disabled = false;
#		owner.get_node("Hitbox/Collision").disabled = false;
