extends "../Motion.gd"

onready var own = get_parent().get_parent();
onready var animation = owner.get_node("Sprite/Animation");
var hit_strength: Vector2;
var damage: int;


func enter():
	if owner.states_stack[1].name == "Stick":
		print("stick to explode")
		owner.current_state.emit_signal("finished", "explode");
		owner.invincible = true;
	
	else:
		damage = owner.hit_stats['damage'];
		hit_strength = owner.hit_stats['hit_strength'];
		
		owner.health -= damage;
		
		animation.play("Hit");
		owner.move_and_slide(hit_strength);
		
		$Cooldown.start();
		
		Sound_Manager.play_sound('hit2.wav');
		owner.get_node("Hit_Particles").emit(hit_strength.x);
	
	if !owner.controlled: 
		get_parent().get_node("AI_Move").can_run = true;
		get_parent().get_node("AI_Move/Run_Cooldown").start();


func exit():
	owner.get_node("Sprite_Handler").clear_shader();


func _on_animation_finished(anim_name):
	if anim_name == "Hit":
		if owner.health <= 0:
			emit_signal("finished", "die");
			return;
		
		if owner.states_stack[1].name == "Attack":
			emit_signal("finished", "idle");
		
		else:
			emit_signal("finished", "previous");


func _on_Cooldown_timeout():
	if not owner.current_state.name in ["Explode"]:
		owner.invincible = false;
