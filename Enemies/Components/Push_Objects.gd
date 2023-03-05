extends Component

export (bool) var can_push = true;
onready var position: Vector2 = owner.position;
onready var motion: Vector2 = owner.motion;
onready var hitbox = owner.get_node("Hitbox");


func update(_delta):
	if !is_active: return;
	
	update_self_vars();
	push_objects();


func update_self_vars():
	position = owner.position;
	motion = owner.motion;


func push_objects():
	if !can_push: return;
	
	for collider in hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object.is_in_group("Pushable"):
			if (position.y >= object.global_position.y - 20) && (position.y < object.global_position.y + 20):
				if (object.global_position.x <= position.x) && (sign(motion.x) == -1):
					collider.owner.push(Vector2(motion.x, 0));
				elif (object.global_position.x >= position.x) && (sign(motion.x) == 1):
					collider.owner.push(Vector2(motion.x, 0));
			
			elif (position.x >= object.global_position.x - 20) && (position.x < object.global_position.x + 20):
				if (object.global_position.y <= position.y) && (sign(motion.y) == -1):
					collider.owner.push(Vector2(0, motion.y));
				elif (object.global_position.y >= position.y) && (sign(motion.y) == 1):
					collider.owner.push(Vector2(0, motion.y));
