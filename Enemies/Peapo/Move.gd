extends "../Motion.gd"

export(float) var ACCELERATION = 1.7;
export(float) var MAX_MOVESPEED = 100;
var current_movespeed = MAX_MOVESPEED;

var input_direction = Vector2.ZERO;

const MOVE_SHADER = "res://Shaders/Move.tres";

onready var sprite = owner.get_node("Sprite");

const FRAME_MAP = {
	"right1": 0,
	"right2": 1,
	"right3": 2,
	"left1": 3,
	"left2": 4,
	"left3": 5,
	"down1": 6,
	"down2": 7,
	"up1": 8,
	"up2": 9
}


func enter():
	sprite.frame = 0;
	owner.speed = MAX_MOVESPEED * 0.1;
	current_movespeed = MAX_MOVESPEED;
	sprite.get_node("Animation").play("Move");
	owner.get_node("Sprite_Handler").change_shader(MOVE_SHADER);

func exit():
	sprite.get_node("Animation").stop();
	sprite.rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();


func update(delta): 
	if input_update(): return;
	move();
	animate();


func input_update():
	input_direction = get_input_direction();
	if input_direction == Vector2.ZERO:
		emit_signal("finished", "idle");

	elif get_attack_input():
		emit_signal("finished", "attack");
	
	elif owner.can_attack:
		emit_signal("finished", "aim");


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
	if sprite.get_node("Animation").get_current_animation() == "New_Seed":
		if input_direction.x == -1: sprite.set_flip(true);
		elif input_direction.x == 1: sprite.set_flip(false);
	
	else:
		if input_direction.x == -1:
			sprite.frame = FRAME_MAP.left1
		elif input_direction.x == 1:
			sprite.frame = FRAME_MAP.right1;


func _on_Bar_Animation_animation_finished(anim_name):
	if owner.current_state != self: return;
	
	if anim_name == "Fill":
		emit_signal("finished", "idle");
