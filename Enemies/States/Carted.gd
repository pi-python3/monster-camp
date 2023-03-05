extends "../Motion.gd"

var cart;


func enter():
	owner = get_parent().owner;
	
	if owner.cart == null:
		emit_signal("finished", "idle");
		return;
	
	cart = owner.cart;
	owner.get_node("Hitbox/Collision").disabled = true;
	owner.get_node("Collision").disabled = true;


func update(delta):
	if weakref(cart).get_ref() != null:
		owner.position = cart.global_position - Vector2(0, 10);
	
	else:
		cart = null;
		emit_signal("finished", "idle");
		return;
	
	if get_attack_input(true): #disregard can_attack variable
		cart.empty_cart();
		emit_signal("finished", "move");


func exit():
	owner.get_node("Hitbox/Collision").disabled = false;
	owner.get_node("Collision").disabled = false;
	
	if weakref(cart).get_ref() != null:
		cart.empty_cart();
	
	if owner.get_node_or_null("Water_Effect") != null: owner.get_node("Water_Effect").hide();
