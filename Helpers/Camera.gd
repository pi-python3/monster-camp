extends Camera2D

#var bounding_box: Rect2;
#var base_dimensions: Vector2;

func _ready():
	position = Vector2(300,300);
#	limit_left = -80;
#	limit_top = 0;
#	limit_bottom = 600;
#	limit_right = 760 - 80;
	
#	base_dimensions = Vector2( abs(limit_left) + limit_right, abs(limit_top) + limit_bottom);
#	zoom = Vector2(0.9,0.9);

#func _process(_delta):
#	if weakref(Monster_Vars.controlled_monster).get_ref() != null:
#		position = weakref(Monster_Vars.controlled_monster).get_ref().global_position;
#
#	bounding_box.position = position - Vector2(300,300);
#	bounding_box.size = base_dimensions * zoom;
##	print(bounding_box)
#	contain_all_creatures();
#
#func contain_all_creatures():
#	for m in Monster_Vars.monsters:
#		var new_box: Rect2;
#		if !bounding_box.has_point(m.global_position):
#			new_box = bounding_box.expand(m.global_position);
#		print(new_box)
