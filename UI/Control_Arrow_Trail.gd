extends Line2D

export(bool) var hide_at_start = false;
export(NodePath) var target_path;
onready var target = get_node(target_path);
export(int) var length = 10;


func _ready():
	if hide_at_start: hide();


func _process(delta):
	global_rotation = 0;
	global_position = Vector2.ZERO;
	
	print(target.global_position);
	add_point(target.global_position);
	
	while get_point_count() > length:
		remove_point(0);
