extends "res://Scripts/State.gd"

export(float) var move_to_cart_speed = 1.5;
var reached_cart := false;


func enter():
	owner.can_push = false;
	owner.get_node("Collision").disabled = true;
	owner.invincible = true;
	owner.get_node("Pickup_Hitbox/Invincible_Wait").start();
	owner.get_node("Sprite/Shadow").hide();


func update(delta):
	if !reached_cart:
		owner.position.x -= move_to_cart_speed * sign(owner.global_position.x - owner.cart.global_position.x) * delta * 10;
		owner.position.y -= move_to_cart_speed * sign(owner.global_position.y - owner.cart.global_position.y) * delta * 10;
		
		if owner.global_position.distance_to(owner.cart.global_position) < 2:
			reached_cart = true;
		else:
			return;
	
	if weakref(owner.cart).get_ref() != null:
		owner.global_position = owner.cart.global_position - Vector2(0, 10);
		owner.invincible = true;
	else:
		emit_signal("finished", "idle");

func exit():
	owner.can_push = true;
	owner.get_node("Collision").disabled = false;
	owner.invincible = false;
	owner.cart = null;
	owner.get_node("Sprite/Shadow").show();
