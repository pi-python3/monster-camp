extends "res://Scripts/State.gd"

func enter():
	owner.invincible = true;
	owner.can_push = false;
	owner.get_node("Hit_Particles2").emitting = true;
	
	if owner.cart != null:
		owner.cart.empty_cart();
		owner.cart = null;
	
	owner.get_node("Hit_Particles/Particle_Wait").start();
	owner.get_node("Sprite").hide();
	owner.set_process(false);
	owner.get_node("Collision").disabled = true;


func _on_Particle_Wait_timeout():
	destroy();


func destroy():
	owner.emit_signal("destroy", self);
	
	owner.hide();
	owner.set_process(false);
	owner.queue_free();
