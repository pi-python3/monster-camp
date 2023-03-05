extends "res://Scripts/State.gd"

func enter():
	owner.get_node("Slide_Hitbox/CollisionShape2D").disabled = true;
	owner.get_node("Pickup_Hitbox/Collision").disabled = true;
	owner.get_node("Move_Particles").emitting = false;
	owner.can_push = true;


#func update(_delta):
#	owner.check_cart_pickup();
