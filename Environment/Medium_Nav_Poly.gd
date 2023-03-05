extends NavigationPolygonInstance

var follow_node;

func _enter_tree():
	set_physics_process(false);


func init(following):
	follow_node = following;
	reset_pos();
	
	set_physics_process(true);


func _physics_process(delta):
	if weakref(follow_node).get_ref() != null:
		reset_pos();
	else:
		destroy();


func reset_pos():
#	print(follow_node.global_position)
	global_position = follow_node.global_position;
	
	enabled = false;
	enabled = true;


func destroy():
	enabled = false;
	queue_free();
