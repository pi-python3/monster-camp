extends TileMap

const grass_tile_chance = float(50.0 / 255.0) * 2.0;
const grass_tile_num = 7;
const ground_tile_id = 19;


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize();
	
	for tile in owner.get_node("Ground").get_used_cells_by_id(ground_tile_id):
		if owner.get_node("Ground").get_cell_autotile_coord(tile.x, tile.y) != Vector2(0,0): continue;
		if owner.get_node_or_null("Water") != null:
			if owner.get_node("Water").get_cell(tile.x, tile.y) != -1: continue;
		
		if rng.randf() <= grass_tile_chance:
			rng.randomize();
			var tile_coord = Vector2(rng.randi_range(1,16),0);
#			if rng.randf() > 0.5: tile_coord = Vector2(1,0);
			
			set_cell(tile.x, tile.y, grass_tile_num, false, false, false, tile_coord);
