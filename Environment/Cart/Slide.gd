extends "res://Scripts/State.gd"

export(float) var slide_speed = 50;
export(float) var hit_slide = 450;
export(float) var friction = 0.04;
var slide_motion := Vector2.ZERO;

func enter():
	owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = true;
	owner.get_node("Pickup_Hitbox/Collision").disabled = true;


func update(_delta):
	if owner.slide_motion != Vector2.ZERO:
		owner.move_and_slide(owner.slide_motion);
		owner.slide_motion *= 1.0 - friction;
		
		if owner.slide_motion.length() <= 0.1:
			owner.slide_motion = Vector2.ZERO;

	else:
		emit_signal("finished", "idle");
