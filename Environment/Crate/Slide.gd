extends "res://Scripts/State.gd"

export(float) var slide_speed = 50;
export(float) var hit_slide = 450;
export(float) var friction = 0.1;
var slide_motion := Vector2.ZERO;


func update(delta):
	if owner.get_node("Sprite").material != null:
		owner.get_node("Sprite").material = null;
	
	if slide_motion != Vector2.ZERO:
		owner.move_and_slide(slide_motion);
		slide_motion *= 1.0 - friction;
		
		if slide_motion.length() <= 0.1:
			slide_motion = Vector2.ZERO;
	
	else:
		emit_signal("finished", "idle");
