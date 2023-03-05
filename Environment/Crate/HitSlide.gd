extends "res://Scripts/State.gd"

const SPEED_SQUASH_SHADER = preload("res://Shaders/Speed_Squash.tres");

var slide_speed = 0;
var hit_slide = 0;
var friction = 0;
var slide_motion := Vector2.ZERO;

func enter():
	owner.can_push = false;
	
	slide_speed = get_parent().get_node("Slide").slide_speed;
	hit_slide = get_parent().get_node("Slide").hit_slide;
	friction = get_parent().get_node("Slide").friction;
	
	slide_motion = owner.hit_stats['hit_strength'] * hit_slide * clamp(owner.hit_stats['damage']*0.5, 0.7, 2);
	
	owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = false;
	owner.get_node("Sprite").material = SPEED_SQUASH_SHADER;


func update(delta):
	owner.motion = Vector2(floor(slide_motion.x * 0.2), floor(slide_motion.y * 0.2));
	
	if slide_motion != Vector2.ZERO:
		if owner.health > 0:
			owner.move_and_slide(slide_motion);
			slide_motion *= 1.0 - friction;
			if slide_motion.length() <= 0.1:
				slide_motion = Vector2.ZERO;
		
		else:
			break_slide(delta);

		if slide_motion.length() < hit_slide * 0.5:
			get_parent().get_node("Slide").slide_motion = slide_motion;
			emit_signal("finished", "slide");
		
	else:
		emit_signal("finished", "idle");


func break_slide(delta):
	var c = owner.move_and_collide(slide_motion * delta * 1.5);
	if c:
		yield(get_tree().create_timer(0.1), "timeout");
		emit_signal("finished", "break");
	slide_motion *= 1.0 - friction;
	if slide_motion.length() < hit_slide * 0.5:
		emit_signal("finished", "break");


func exit():
	owner.can_push = true;
	owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = true;
	owner.get_node("Sprite").material = null;
	
	for source in owner.hit_sources:
		if owner in source.protected_from:
			source.protected_from.erase(owner);
