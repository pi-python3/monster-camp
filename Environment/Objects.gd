extends TileMap

const EXPLOSIVE_BARREL = preload("res://Environment/Explosive_Barrel.tscn");
const CRATE = preload("res://Environment/Crate/Crate.tscn");
const CART = preload("res://Environment/Cart/Cart.tscn");
const TORCH_LIGHT = preload("res://Environment/Torch_Light.tscn");
const SKULL_CHEST = preload("res://Environment/Skull_Chest/Skull_Chest.tscn");

const object_name = {
	2: "explosive_barrel",
	3: "crate",
	4: "cart",
	6: "torch_light",
	7: "torch_light",
	8: "skull_chest"
};

const no_delete = [5,6,7];

var stored_cells = [];


func _ready():
	for cell in get_used_cells():
		var cell_id = get_cell(cell.x, cell.y);
		if not (cell_id in object_name.keys()): continue;
		
		var object = spawn_object(cell, self.get(object_name[cell_id].to_upper()));
		stored_cells.append([cell, cell_id, object]);
		if not cell_id in no_delete:
			set_cell(cell.x, cell.y, -1);
	
	set_shadows();


func spawn_object(cell_pos: Vector2, object, uncenter=true):
	var o = object.instance();
	add_child(o);
	o.connect("destroy", self, "_on_object_destroy");
	o.global_position = ( map_to_world(cell_pos, true) + (Vector2(4,4)*int(uncenter)) ) * 5;
	return o;


func _on_object_destroy(object):
	var object_cell;
	
	for cell in stored_cells:
		if object == cell[2]:
			object_cell = cell;
			break;


func set_shadows():
	for tile in get_used_cells():
		if get_cell(tile.x, tile.y) == 0 && get_cell(tile.x, tile.y + 1) == -1: #if tile is object and tile below is empty
			set_cell(tile.x, tile.y + 1, 1, false, false, false, get_cell_autotile_coord(tile.x, tile.y));
