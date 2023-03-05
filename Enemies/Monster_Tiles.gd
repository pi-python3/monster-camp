extends TileMap

onready var monster_y_sort = get_parent().get_node("Monsters");

const BOKO = preload("res://Enemies/Boko/Boko.tscn");
const SKELE = preload("res://Enemies/Skele/Skele.tscn");
const KEESEE = preload("res://Enemies/Keesee/Scar.tscn");
const PEAPO = preload("res://Enemies/Peapo/Peapo.tscn");
const BOMBO = preload("res://Enemies/Bombo/Bombo.tscn");
const DRILLGI = preload("res://Enemies/Drillgi/Drillgi.tscn");

const object_name = {
	0: "boko",
	1: "skele",
	2: "keesee",
	3: "peapo",
	4: "bombo",
	5: "drillgi"
};

var stored_cells = [];


func _ready():
	for cell in get_used_cells():
#		var cell_id = get_cell(cell.x, cell.y);
		var cell_coord = get_cell_autotile_coord(cell.x, cell.y);
		
		var object = spawn_object(cell, self.get(object_name.get(int(cell_coord.x)).to_upper()));
	
	clear();
#		stored_cells.append([cell, cell_id, object]);


func spawn_object(cell_pos: Vector2, object, uncenter:=true):
	var o = object.instance();
	monster_y_sort.add_child(o);
#	o.connect("destroy", self, "_on_object_destroy");
	o.global_position = ( map_to_world(cell_pos, true) + (Vector2(4,4)*int(uncenter)) ) * 5;
	return o;


func _on_object_destroy(object):
#	var object_cell;
	
	for cell in stored_cells:
		if object == cell[2]:
#			object_cell = cell;
			break;
