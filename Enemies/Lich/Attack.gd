extends "../Motion.gd"

const FIREBALL = preload("res://Enemies/Lich/Fireball/Lich_Fireball.tscn");

export(float) var DECELERATE = 0.7;

var input_direction: Vector2;
onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");

func enter():
	if !owner.can_attack: emit_signal("finished", "idle");
	owner.can_attack = false;
	
	animate();
	attack_animation();
	
#	owner.motion = Vector2.ZERO;
	
	Sound_Manager.play_sound("Slash.wav");


func attack_animation():
	if sprite.get_flip():
		slash_effect.get_node("Slash_Animation").play("Attack Right");
	else:
		slash_effect.get_node("Slash_Animation").play("Attack Right");


func exit():
	sprite.frame = 0;
	owner.get_node("Stamina_Bar").fill();
	return;


func update(delta):
	animate();
	move();


func animate():
	sprite.scale.x = clamp(sprite.scale.x * 1000, -1, 1);
#	$Slash_Effect.global_position = sprite.global_position;
#	if sprite.get_flip(): slash_effect.offset.x = -8;
	slash_effect.offset.x = 8;
#	slash_effect.flip_h = sprite.get_flip();

func move():
	owner.motion *= DECELERATE;
	if owner.motion.length() < 0.1: owner.motion = Vector2.ZERO;
	owner.move_and_slide(owner.motion);


func spawn_fireball(_rotation_add := 0.0):
	var fireball = FIREBALL.instance();
	owner.owner.add_child(fireball);
	
	var num_dir = 1;
	if sprite.get_flip(): num_dir = -1;
	var rot_vector = Vector2(cos(deg2rad(_rotation_add)), sin(deg2rad(_rotation_add)));
	rot_vector *= num_dir;
	
	fireball.global_position = owner.global_position + slash_effect.position + slash_effect.offset + Vector2(8*num_dir,-4*5);
	fireball.shoot(owner, rot_vector);


func _on_Cooldown_Timer_timeout():
	emit_signal("finished", "idle");


func _on_Slash_Animation_animation_finished(anim_name):
	slash_effect.visible = false;
	spawn_fireball();
	spawn_fireball(25);
	spawn_fireball(-25);
	$Cooldown_Timer.start();
