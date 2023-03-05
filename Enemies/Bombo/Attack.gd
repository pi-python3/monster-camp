extends "../Motion.gd"

const JUMP_PATH = preload("res://Enemies/Bombo/Jump_Path.tscn");
var jump_path;

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");

export(float) var JUMP_ANGLE = 20;
export(float) var ATTACK_MOVE_SPEED = 30;


func enter():
	owner.can_attack = false;
	animate();
	
	var input_dir = get_global_input_direction();
	if input_dir == Vector2.ZERO:
		if owner.get_node("Sprite").flip_h: input_dir = Vector2.LEFT;
		else: input_dir = Vector2.RIGHT;
	
	var degrees = rad2deg(input_dir.angle());
	if degrees < 0: degrees = degrees + 360;
	degrees = int(round(degrees));
	
	if degrees < 90 || degrees > 270: degrees -= JUMP_ANGLE;
	else: degrees += JUMP_ANGLE;
	degrees = deg2rad(degrees);
	
	jump_path = JUMP_PATH.instance();
	get_parent().add_child(jump_path);
	jump_path.global_position = owner.global_position;
	
	if input_dir.x < 0:
		jump_path.scale.x *= -1;
	
	owner.get_node("Trail").show();
	sprite.frame = 1;
	
	Sound_Manager.play_sound('Keesee_Attack.wav');


func update(delta):
	var path_follow = jump_path.get_node("Path_Follow");
	move(delta);
	animate();
	
	if path_follow.unit_offset >= 1:
		path_follow.queue_free();
		emit_signal("finished", "idle");


func move(delta):
	var path_follow = jump_path.get_node("Path_Follow");
	
	path_follow.unit_offset += ATTACK_MOVE_SPEED * delta / 10;
	
	owner.motion = path_follow.global_position - owner.global_position;
	var collide = owner.move_and_collide(owner.motion);
	
	if collide:
		stick_detection(collide);


func stick_detection(collide):
	var collider = collide.collider;
	
	if collider.is_in_group("Monster") || collider.is_in_group("Interactable"):
		owner.stick_target = collider;
		emit_signal("finished", "stick");


func animate():
	pass;


func exit():
	owner.get_node("Stamina_Bar").fill();
	owner.get_node("Trail").hide();
	sprite.frame = 0;
	return;
