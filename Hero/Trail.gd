extends Line2D

export(bool) var hide_at_start = false;
onready var target = owner;
export(int) var length = 10;


func _ready():
	if hide_at_start: hide();


func _process(delta):
	global_position = Vector2.ZERO;
	global_rotation = 0;
	
	add_point(target.global_position / 5);
	
	while get_point_count() > length:
		remove_point(0);
