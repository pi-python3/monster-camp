extends "res://Scripts/State.gd"

var slide_speed = 0;
var hit_slide = 0;
var friction = 0;
var slide_motion := Vector2.ZERO;

func enter():
	owner.can_push = false;
	
	slide_speed = get_parent().get_node("Slide").slide_speed;
	hit_slide = get_parent().get_node("Slide").hit_slide;
	friction = get_parent().get_node("Slide").friction;
	
	slide_motion = owner.hit_stats['hit_strength'] * hit_slide;
	
	owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = owner.carted_object == null;
	owner.get_node("Pickup_Hitbox/Collision").disabled = owner.carted_object != null;


func update(delta):
	if slide_motion != Vector2.ZERO:
		owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = owner.carted_object == null;
		owner.get_node("Pickup_Hitbox/Collision").disabled = owner.carted_object != null;
		
		owner.move_and_slide(slide_motion);
		slide_motion *= 1.0 - friction;
		if slide_motion.length() <= 0.1:
			slide_motion = Vector2.ZERO;
		
#	else:
#		break_slide(delta);

		if slide_motion.length() < hit_slide * 0.3:
			get_parent().get_node("Slide").slide_motion = slide_motion;
			owner.slide_motion = slide_motion;
			emit_signal("finished", "slide");
		
		owner.slide_motion = slide_motion;
		
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
	owner.get_node("Pickup_Hitbox/Collision").disabled = true;

	owner.clear_protected();
	owner.hit_sources.clear();
