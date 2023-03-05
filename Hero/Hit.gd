extends "Hero_State.gd"

var stunned = false;
var hit_strength = 0;
export(float) var hit_move = 1000;


func enter():
	stunned = owner.hit_stats['stun'];
	hit_strength = owner.hit_stats['hit_strength'];
	
	#flip direction away from attack if stunned
	if stunned: owner.get_node("Sprite").set_flip(hit_strength.x < 0);
	
	owner.get_node("Sprite/Animation").play("Hit");
	owner.move_and_slide(hit_strength * hit_move * clamp(owner.hit_stats['damage']/2, 0, 2));
	$Cooldown.start();
	
	Sound_Manager.play_sound("Hit.wav");
	
	owner.get_node("Hit_Particles").emit(hit_strength.x);
	
	owner.get_node("Sprite/Slash_Effect/Slash_Hitbox").offset_off(); #reset hitbox pos in case of getting hit mid attack

func _on_animation_finished(anim_name):
	if anim_name == "Hit":
		owner.invincible = false;
		
		if Hero_Vars.health <= 0:
			owner.get_node("Sprite").set_flip(hit_strength.x < 0);
			emit_signal("finished", "die");
		
		elif stunned:
			stunned = false;
			emit_signal("finished", "stunned");
		
		elif owner.states_stack.size() >= 2:
			if owner.states_stack[1].name in ["Throw_Boomerang"]:
				emit_signal("finished", "idle");
			
			else:
#				if stunned: owner.get_node("Sprite").set_flip(hit_strength >= 0);
				if Hero_Vars.stamina > 0: owner.get_node("Emotion_Sign").show_emotion("angry");
				emit_signal("finished", "previous");
			
		
		else:
#			if stunned: owner.get_node("Sprite").set_flip(hit_strength >= 0);
			if Hero_Vars.stamina > 0: owner.get_node("Emotion_Sign").show_emotion("angry");
			emit_signal("finished", "idle");


func _on_Cooldown_timeout():
	owner.hit_sources.clear();


func exit():
	owner.get_node_or_null("Sprite_Handler").flash_off();
