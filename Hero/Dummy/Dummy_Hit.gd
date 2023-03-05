extends "res://Hero/Hero_State.gd"

func enter():
	owner.get_node("Sprite/Animation").play("Hit");
	owner.get_node("Sprite").rotation_degrees = 30 * owner.hit_stats["hit_strength"].x;
	$Cooldown.start();
	
	Sound_Manager.play_sound("Hit.wav");
	
	owner.get_node("Target").hide();


func exit():
	owner.hit_dir = 0;
	owner.get_node("Sprite").rotation_degrees = 0;


func _on_animation_finished(anim_name):
	if anim_name == "Hit":
			emit_signal("finished", "previous");


func _on_Cooldown_timeout():
#	$Invincibility_Animation.stop();
	owner.invincible = false;
