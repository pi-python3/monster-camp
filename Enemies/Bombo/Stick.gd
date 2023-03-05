extends "../Motion.gd"

var stick_target;
var offset;


func enter():
	if owner.stick_target == null:
		emit_signal("finished", "idle");
		return;
	
	owner.can_push = false;
	owner.remove_from_group("Cartable");
	
	stick_target = owner.stick_target;
	offset = owner.global_position - stick_target.global_position;
	
	owner.get_node("Collision").disabled = true;
	
	owner.get_node("Sprite").frame = 1;
	


func update(_delta):
	if weakref(stick_target).get_ref() != null:
		owner.position = stick_target.global_position + offset;
	
	elif weakref(stick_target).get_ref() == null:
		stick_target = null;
		owner.add_to_group("Cartable");
		emit_signal("finished", "idle");
		return;


func exit():
	owner.get_node("Collision").disabled = false;
