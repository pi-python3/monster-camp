extends "Motion.gd"

onready var own = get_parent().get_parent();
onready var animation = owner.get_node("Sprite/Animation");
var hit_strength;
export(float) var hit_move = 800;
export(Animation) var HIT_ANIMATION = preload("res://Enemies/Hit_Anim.tres");
export(bool) var pause_on_death = true;
var damage;


func enter():
	damage = owner.hit_stats['damage'];
	hit_strength = owner.hit_stats['hit_strength'];
	
	Sound_Manager.play_sound('hit2.wav');
	owner.get_node("Effects").emit_hit_particles(hit_strength.x);
	
	if owner.health <= 0 && !pause_on_death:
		emit_signal("finished", "die");
		return;
	
	animation.add_animation("hit_anim", HIT_ANIMATION);
	animation.play("hit_anim");
	owner.move_and_slide(hit_strength * hit_move);
	
	$Cooldown.start();


func exit():
	owner.get_node("Sprite_Handler").clear_shader();
	
	if !owner.controlled && get_parent().get_node_or_null("AI_Run") != null: 
		get_parent().get_node("AI_Run").can_run = true;
		get_parent().get_node("AI_Run/Run_Cooldown").start();


func _on_animation_finished(anim_name):
	if anim_name == "hit_anim":
		if owner.health <= 0:
			emit_signal("finished", "die");
			return;
		
		if owner.states_stack[1].name == "Attack":
			emit_signal("finished", "idle");
		
		else:
			emit_signal("finished", "previous");


func _on_Cooldown_timeout():
	owner.invincible = false;
