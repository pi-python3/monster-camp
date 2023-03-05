extends "Hero_State.gd"

onready var sprite = owner.get_node("Sprite");


func enter():
	sprite.get_node("Animation").stop();
	sprite.set_flip(sprite.get_flip(), false);
	
	if sprite.flip_h:
		sprite.get_node("Animation").play("Death_Left");
	else:
		sprite.get_node("Animation").play("Death_Right");
	
	Sound_Manager.play_sound("Death.wav");
	
	owner.get_node("Emotion_Sign").disappear();
	
	Global_Effects.slow_motion(50);
	Global_Camera.zoom_on_position(owner.global_position, 2.5, 0.05); #2.5 zoom


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Death_Left" || anim_name == "Death_Right":
		Global_Effects.slow_motion(0);
		Global_Camera.reset_zoom(1);
		
		yield(get_tree().create_timer(0.3),"timeout");
		if Monster_Vars.monsters.size() > 0:
			Level_Handler.level_over("win");
