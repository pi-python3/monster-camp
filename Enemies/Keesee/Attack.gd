extends "../Motion.gd"

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");
export(int) var ATTACK_MOVE_SPEED = 300;
var attack_move = Vector2(1,1) * ATTACK_MOVE_SPEED;


func enter():
	owner.can_attack = false;
	
	var input_dir = get_parent().get_node("Move").final_input_direction; #get_global_input_direction();
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.RIGHT;
#		if owner.get_node("Sprite").flip_h: input_dir = Vector2.LEFT;

	get_parent().get_node("Move").final_input_direction = input_dir;
	
	animate(input_dir.x);
	
	owner.attack_direction = input_dir.normalized();
	
	owner.get_node("Trail").show();
	
	attack_move = input_dir * ATTACK_MOVE_SPEED;
	if input_dir.x != 0 && input_dir.y != 0: attack_move /= sqrt(2);
	owner.motion = attack_move;
	
	if sprite.get_flip(): #left
		input_dir.x *= -1;
	
	var degrees = rad2deg(input_dir.angle());
	if degrees < 0: degrees = degrees + 360;
	degrees = int(round(degrees));
	slash_effect.rotation_degrees = degrees;
	
	slash_effect.get_node("Slash_Animation").play("Slash");
	
	Sound_Manager.play_sound('Keesee_Attack.wav');

# Clean up the state. Reinitialize values like a timer
func exit():
	owner.get_node("UI").stamina_bar_fill();
	owner.get_node("Trail").hide();
	return;

func update(_delta):
	move();
	animate(get_parent().get_node("Move").final_input_direction.x);
	
	attack_move *= 0.9;
	if attack_move.length() <= 10:
		emit_signal("finished", "idle");


func move():
	owner.motion = attack_move;
	owner.move_and_slide(owner.motion);


func animate(dir_x):
#	$Slash_Effect.global_position = sprite.global_position;
	if sign(dir_x) == -1:
		slash_effect.offset.x = -8;
	else:
		slash_effect.offset.x = 8;
	slash_effect.flip_h = sign(dir_x) == -1;
