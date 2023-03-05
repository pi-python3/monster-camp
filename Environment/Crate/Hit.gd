extends "res://Scripts/State.gd"

onready var sprite = owner.get_node("Sprite");
onready var animation = owner.get_node("Sprite/Animation");
onready var slide_speed = get_parent().get_node("Slide").slide_speed;


func enter():
	animation.play("Hit");
	owner.invincible = true;
	
	Sound_Manager.play_sound("Hit_Wood.wav");
	owner.get_node("Hit_Particles").emitting = true;
	
	var health_percent = (float(owner.health) / float(owner.MAX_HEALTH));

	if health_percent < 0.34:
		sprite.frame = 2;
		slide_speed = 60;
	elif health_percent < 0.67:
		sprite.frame = 1;
		slide_speed = 50;
	else:
		sprite.frame = 0;
		slide_speed = 40;
	
	emit_signal("finished", "hit_slide");


func exit():
	$Cooldown.start();


func _on_Cooldown_timeout():
	owner.invincible = false;
