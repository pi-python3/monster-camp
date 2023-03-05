extends "../Motion.gd"

export(float) var MAX_SLOW_MOVESPEED = 20;
onready var ACCELERATION = get_parent().get_node("Move").ACCELERATION;

var input_direction = Vector2.ZERO;
var aim_direction = Vector2.RIGHT;

const IDLE_SHADER = "res://Shaders/Idle.tres";

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
	if owner.health <= 0: 
		emit_signal("finished", "die");
		return;
	
	sprite.frame = 0;
	owner.speed = MAX_SLOW_MOVESPEED * 0.1;
	get_parent().get_node("Move").current_movespeed = MAX_SLOW_MOVESPEED;
	owner.get_node("Sprite_Handler").change_shader(IDLE_SHADER);

func exit():
	owner.get_node("Sprite_Handler").clear_shader();


func update(delta):
	input_update();
	move();
	animate();


func input_update():
	input_direction = get_input_direction();
	
	if input_direction == Vector2.ZERO:
		emit_signal("finished", "idle");
	
	elif get_attack_input():
		emit_signal("finished", "attack");


func move():
	var motion = owner.motion;
	var speed = owner.speed;
	
	motion = input_direction * speed;
	
	#adjust speed for diagonal movement
	if input_direction.x != 0 && input_direction.y != 0: 
		motion /= sqrt(2);
	
	#accelerate
	speed = clamp(speed * ACCELERATION, MAX_SLOW_MOVESPEED * 0.1, MAX_SLOW_MOVESPEED);
	
	owner.motion = motion;
	owner.speed = speed;
	owner.move_and_slide(owner.motion); #move


func animate():
	if input_direction.x == -1: 
		sprite.frame = FRAME_MAP.left1;
		aim_direction = Vector2.LEFT;
	elif input_direction.x == 1: 
		sprite.frame = FRAME_MAP.right1;
		aim_direction = Vector2.RIGHT;
	
	if input_direction.y == -1: 
		sprite.frame = FRAME_MAP.up1;
		aim_direction = Vector2.UP;
	elif input_direction.y == 1: 
		sprite.frame = FRAME_MAP.down1;
		aim_direction = Vector2.DOWN;
