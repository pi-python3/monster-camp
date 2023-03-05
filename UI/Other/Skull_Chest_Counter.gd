extends Label

func _ready():
	$Particles.emitting = false;


func _process(_delta):
	text = str(Game_Data.skull_chests) + "/" + str(Level_Handler.MAX_LEVELS);
	rect_pivot_offset = rect_size/2;
	
	if Game_Data.skull_chests >= Level_Handler.MAX_LEVELS:
		modulate = Color('ffe478');
		$Particles.emitting = true;
		
		var objects = owner.get_node("Environment/Objects");
		for obj in objects.get_used_cells_by_id(0):
			if objects.get_cell_autotile_coord(obj.x, obj.y) == Vector2(5,0):
				objects.set_cell(obj.x, obj.y, -1);
				objects.set_cell(obj.x, obj.y + 1, -1);
