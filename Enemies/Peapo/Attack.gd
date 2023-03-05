extends "../Motion.gd"

var input_direction: Vector2;
onready var animation = owner.get_node("Sprite/Animation");

const ANIMATION_DIRECTION = {
	Vector2.RIGHT: "Shoot_Right",
	Vector2.LEFT: "Shoot_Left",
	Vector2.DOWN: "Shoot_Down",
	Vector2.UP: "Shoot_Up"
};

const SEED = preload("res://Enemies/Peapo/Seed.tscn");


func enter():
	var aim_direction = get_parent().get_node("Aim").aim_direction;
	owner.can_attack = false;
	
	Sound_Manager.play_sound("Shoot.wav");
	
	animation.play(ANIMATION_DIRECTION.get(aim_direction));
	
	var s = SEED.instance();
	owner.get_parent().add_child(s);
	s.shoot(owner, aim_direction);
	
#	owner.get_node("Stamina_Bar/Seed_Refill_Wait").wait_time = owner.get_node("Stamina_Bar/Bar_Animation").get_animation("Fill").get_length() - animation.get_animation("New_Seed").get_length();
#	owner.get_node("Stamina_Bar/Seed_Refill_Wait").start();


func exit():
	owner.get_node("UI").stamina_bar_fill();


func _on_Animation_animation_finished(anim_name):
	if "Shoot" in anim_name:
		emit_signal("finished", "idle");


func _on_Seed_Refill_Wait_timeout():
	pass;
#	animation.play("New_Seed");
#	yield(get_tree().create_timer(0.3), "timeout");
#	if owner.controlled && owner.current_state.name != "Die":
#		Sound_Manager.play_sound("Seed_Refill.wav");
