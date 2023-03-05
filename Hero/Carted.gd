extends "Hero_State.gd"

var cart;
onready var animation = owner.get_node("Sprite/Animation");


func enter():
	owner.invincible = true;
	
	if owner.cart == null:
		emit_signal("finished", "idle");
		return;
	
	cart = owner.cart;
	owner.get_node("Hitbox/CollisionShape2D").disabled = true;
	owner.get_node("Collision").disabled = true;
	
	owner.get_node("Sprite").rotation_degrees = 0;
	animation.play("Carted");


func update():
	if weakref(cart).get_ref() != null:
		owner.position = cart.global_position - Vector2(0, 10);
	
	else:
		emit_signal("finished", "idle");
		return;


#func is_in_water():
#	if owner.get_node_or_null("Foot_Hitbox") != null:
#		for collider in owner.get_node("Foot_Hitbox").get_overlapping_bodies():
#			if collider is TileMap:
#				print("tile!!!")
#			if collider.is_in_group("Water"):
#				return true;
#
#	return false;


func _on_Animation_animation_finished(anim_name):
	if anim_name == "Carted" && owner.current_state == self:
		emit_signal("finished", "move");


func exit():
	owner.get_node("Hitbox/CollisionShape2D").disabled = false;
	owner.get_node("Collision").disabled = false;
	owner.invincible = false;
	
	if weakref(cart).get_ref() != null:
		cart.empty_cart();
	
	cart = null;
	owner.cart = null;
