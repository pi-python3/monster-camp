extends "../Motion.gd"

const CLAP_EXPLOSION = preload("res://Enemies/Norman/Clap_Explosion.tscn");

export(String) var sound_effect = 'Slash.wav';

onready var sprite = owner.get_node("Sprite");
onready var slash_effect = owner.get_node("Sprite/Slash_Effect");
onready var slash_animation: AnimationPlayer = owner.get_node("Sprite/Slash_Effect/Slash_Animation");

var played_clap_sfx := false;
var left_hand: KinematicBody2D;
var right_hand: KinematicBody2D;


func _ready():
	if "left" in owner.name.to_lower():
		left_hand = owner;
		right_hand = owner.get_parent().find_node("*Right");
	
	else:
		right_hand = owner;
		left_hand = owner.get_parent().find_node("*Left");


func enter():
	if !owner.can_attack: emit_signal("finished", "idle");
	owner.can_attack = false;
	
	if "left" in owner.name.to_lower():
		attack_animation(1);
	
	else:
		attack_animation(-1);
	
	played_clap_sfx = false;
#	Sound_Manager.play_sound(sound_effect);


func attack_animation(dir: int):
	dir = sign(dir);
	owner.motion = Vector2(0,0);
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC);
	#move back
	tween.tween_property(owner, "motion", Vector2(-200 * dir, 0), 0.1);
	tween.parallel().tween_property(sprite, "rotation_degrees", 25.0, 0.2);
#	tween.tween_interval(0.1);
	#slow down
	tween.tween_property(owner, "motion", Vector2(0,0), 0.1);
	
	#activate hitbox and set frame
	tween.tween_callback(slash_effect.get_node("Slash_Hitbox/CollisionShape2D"), "set", ["disabled", false]);
	tween.tween_callback(sprite, "set", ["frame", 1]);

	#move forward super fast
	tween.tween_property(owner, "motion", Vector2(800 * dir, 0), 0.2);
	tween.tween_callback(sprite, "set", ["frame", 0]);
	
	#slwo down to stop
	tween.tween_property(owner, "motion", Vector2(0, 0), 0.1);
	tween.parallel().tween_property(sprite, "rotation_degrees", -15.0, 0.2);
	tween.tween_callback(slash_effect.get_node("Slash_Hitbox/CollisionShape2D"), "set", ["disabled", true]);
	tween.tween_callback(self, "screen_shake_on_clap", []);
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.2);
	tween.tween_callback(self, 'emit_signal', ["finished", "idle"]);


func exit():
	owner.get_node("UI").stamina_bar_fill();
	owner.remove_from_group("Stun_Attack");
	return;


func update(_delta):
	move();
	activate_stun(check_hand_clap());


func move():
	owner.move_and_slide(owner.motion);


func check_hand_clap() -> bool:
	var clap_distance = 100;
	var y_align_distance = 50;
	
	var y_aligned = abs(right_hand.global_position.y - left_hand.global_position.y) <= y_align_distance;
	var x_aligned = right_hand.global_position.x - left_hand.global_position.x < clap_distance;
	var alive = right_hand.health > 0 && left_hand.health > 0;
	
	return y_aligned && x_aligned && alive;


func activate_stun(hand_clap: bool) -> void:
	if !owner.is_in_group("Stun_Attack") && hand_clap:
		owner.add_to_group("Stun_Attack");
	elif !hand_clap && owner.is_in_group("Stun_Attack"):
		owner.remove_from_group("Stun_Attack");
	
	if hand_clap && !played_clap_sfx && !slash_effect.get_node("Slash_Hitbox/CollisionShape2D").disabled:
		spawn_clap_explosion();
		Sound_Manager.play_sound("Clap.wav");
		played_clap_sfx = true;


func screen_shake_on_clap():
	if check_hand_clap():
		Global_Camera.shake("explosion");


func spawn_clap_explosion():
	var spawn_pos = (left_hand.global_position + right_hand.global_position) * 0.5
	
	var explosion = CLAP_EXPLOSION.instance();
	owner.get_parent().add_child(explosion);
	explosion.spawn(spawn_pos);
