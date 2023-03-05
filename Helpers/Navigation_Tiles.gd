tool
extends TileMap

onready var game = get_parent().get_parent();

const tile_types = {
	"green": Vector2(0,0),
	"red": Vector2(1,0),
	"blue": Vector2(2,0)
};

const PATH_NODE = preload("res://Helpers/Path_Node.gd");
var path_nodes := {};


func _on_Navigation_Tiles_visibility_changed():
	recalculate_tiles();

func _ready():
	recalculate_tiles();


func recalculate_tiles():
	clear();
	game = get_parent().get_parent();
#	print("NAV TILES RESET!");

#--------SET ALL GROUND TILES TO NAVIGABLE------------
	var ground = game.get_node("Ground");
	for tile in ground.get_used_cells():
		if ground.get_cell(tile.x, tile.y) in [6, 18]: #if black tile or natural static object
			spawn_tile(tile, "red");
		else:
			spawn_tile(tile, "green")

#--------SET ALL WATER TILES TO NON-NAVIGABLE------------
	var water = game.get_node_or_null("Water");
	if water != null:
		for tile in water.get_used_cells():
			spawn_tile(tile, "blue"); #place non navigable tile
			#surrounding tiles
#			spawn_tile_double(tile*2 - Vector2(1,0), "blue");
#			spawn_tile_double(tile*2 + Vector2(1,0), "blue");
#			spawn_tile_double(tile*2 - Vector2(0,1), "blue");
#			spawn_tile_double(tile*2 + Vector2(0,1), "blue");
#--------SET ALL OBJECT TILES TO NON-NAVIGABLE------------
	var objects = game.get_node("Environment/Objects");
	var object_tiles = objects.get_used_cells();
	
	for tile in object_tiles:
#		print(objects.get_cell(tile.x, tile.y))
		if objects.get_cell(tile.x, tile.y) in [0,8]: #add 2 to add explosive barrel #if not a shadow
			spawn_tile(tile, "red"); #place non navigable, raycast collision tile


func spawn_tile(pos: Vector2, type: String):
	var small_tile_id := 0;
	set_cell(pos.x, pos.y, small_tile_id, false, false, false, tile_types[type]);
	
	var p_node = PATH_NODE.PathNode.new();
	path_nodes[pos] = p_node;
	p_node.init(pos, type);


func spawn_tile_double(pos: Vector2, type: String):
	spawn_tile(pos, type);
	spawn_tile(Vector2(pos.x + 1, pos.y), type);
	spawn_tile(Vector2(pos.x, pos.y + 1), type);
	spawn_tile(Vector2(pos.x + 1, pos.y + 1), type);


func _on_Calculate_Wait_timeout():
	return;
	
	recalculate_tiles();
	print("new calc")
#--------SET ALL INTERACTABLES TILES TO NON-NAVIGABLE------------
	var interactables = game.get_node("Environment/Objects").get_children();
	for i in interactables:
		var tile_pos = world_to_map(i.global_position - Vector2(10,10))/5;
		print(tile_pos);
		set_cell(tile_pos.x, tile_pos.y, 3, false, false, false, tile_types["red"]);
		spawn_tile_double(tile_pos, "red");
	
#	update_dirty_quadrants();


const GRID_SIZE = Vector2(16*4, 16*4);

func get_neighbours(node):
	var neighbours = [];
	
	for x in range(3):
		for y in range(3):
			var offset = Vector2(x - 1, y - 1);
			if offset == Vector2.ZERO: continue;
			
			var check = node.pos + offset;
			if check.x >= -2 && check.x < GRID_SIZE.x - 2 && check.y >= -2 && check.y < GRID_SIZE.y - 2: 
				neighbours.append(path_nodes[check]);
	
	return neighbours;
